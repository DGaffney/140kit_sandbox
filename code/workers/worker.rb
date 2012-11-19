load File.dirname(__FILE__)+'/../environment.rb'
load File.dirname(__FILE__)+'/../analyzer/analysis.rb'
class Worker < Instance
  
  # attr_accessor :user_account, :username, :password, :start_time, :next_dataset_ends, :queue, :params, :datasets
  attr_accessor :curation, :last_system_check
  
  @@words = File.open(File.dirname(__FILE__)+"/../analyzer/resources/words.txt", "r").read.split
  @@rest_analytics = ["retweet_graph"]
  $drop_interval = lambda{Setting.first(:name => "drop_interval").value} rescue 60*60*24*2
  $hide_interval = lambda{Setting.first(:name => "hide_interval").value} rescue 60*60*24*7*4
  $clean_orphan_interval = lambda{Setting.first(:name => "clean_orphan_interval").value} rescue 900
  def initialize
    super
    self.instance_type = "worker"
    self.save
    # @datasets = []
    # @queue = []
    at_exit { do_at_exit }
  end
  
  def do_at_exit
    puts "Exiting."
    unlock
    self.destroy
  end
  
  def work
    puts "Working..."
    check_in
    puts "Entering work routine."
    $instance = self
    loop do
      if !killed?
        work_routine
      else
        puts "Just nappin'."
        sleep(@sleep_constant.call)
      end
    end
  end
  
  def work_routine
    clean_orphans
    do_analysis_jobs
    switch_curation_statuses
  end
  
  def switch_curation_statuses
    statuses = Setting.first(:name => "statuses", :var_type => "Dataset Settings").value
    unflippable_statuses = Setting.first(:name => "unflippable_statuses", :var_type => "Dataset Settings").value
    Curation.all(:status => ["tsv_stored", "imported"]).unlocked.each do |curation|
      datasets = curation.datasets
      if curation.tweets_count == 0 && curation.finished? && curation.status != "tsv_storing"
        datasets.each do |dataset|
          dataset.status = "zero_data"
          dataset.save!
        end
        curation.status = "zero_data"
        Notification.post("@#{curation.researcher.user_name}: Your data is now ready for import on #140kit: http://140kit.com/datasets/#{curation.id}") if curation.researcher.share_email
        curation.save!
      end
    end
    Curation.all(:status.not => unflippable_statuses).unlocked.each do |curation|
      datasets = curation.datasets
      if curation.tweets_count == 0 && curation.finished? && curation.status != "tsv_storing"
        datasets.each do |dataset|
          dataset.status = "zero_data"
          dataset.save!
        end
        curation.status = "zero_data"
        curation.save!
      elsif datasets.length == datasets.collect{|x| x.status if x.status == statuses[statuses.index(curation.status)+1]}.compact.length
        curation.status = statuses[statuses.index(curation.status)+1] 
        curation.save!
        if curation.status == "imported"
          Notification.post("@#{curation.researcher.user_name}: Your data is now ready for import on #140kit: http://140kit.com/datasets/#{curation.id}") if curation.researcher.share_email
        elsif curation.status == "tsv_stored"
          Notification.post("@#{curation.researcher.user_name}: Your data is now stored on #140kit: http://140kit.com/datasets/#{curation.id}") if curation.researcher.share_email
        elsif curation.status == "dropped"
          Notification.post("@#{curation.researcher.user_name}: Your data is now archived on #140kit: http://140kit.com/datasets/#{curation.id}") if curation.researcher.share_email
        end
      end
    end
    Curation.all(:updated_at.lte => Time.now-$drop_interval.call, :status => "imported").each do |curation|
      analysis_metadatas = curation.analysis_metadatas
      if AnalysisMetadata.all(:id => analysis_metadatas.collect(&:id)).unlocked.length == analysis_metadatas.length
        curation.status = "needs_drop"
        curation.datasets.each do |dataset|
          dataset.status = "needs_drop"
          dataset.save!
        end
        curation.save!
      end
    end
    Curation.all(:updated_at.lte => Time.now-$hide_interval.call, :status => "dropped").each do |curation|
      analysis_metadatas = curation.analysis_metadatas
      if AnalysisMetadata.all(:id => analysis_metadatas.collect(&:id)).unlocked.length == analysis_metadatas.length
        curation.status = "hidden"
        curation.datasets.each do |dataset|
          dataset.status = "hidden"
          dataset.save!
        end
        curation.save!
      end
    end
  end
  
  def select_curation
    curations = Curation.unlocked.all(:status.not => ["tsv_storing"]).reject {|c| c.datasets.collect {|d| d.scrape_finished }.include?(false) }.shuffle
    for curation in curations
      curation.lock
      return curation if curation.owned_by_me?
    end
    return nil
  end
  
  def clean_orphans
    return if !self.last_system_check.nil? && (Time.now-self.last_system_check) < $clean_orphan_interval.call
    Instance.all.each do |instance|
      process_report = self.hostname == instance.hostname ? Sh::bt("ps -p #{instance.pid}").split("\n") : Sh::bt("ssh #{instance.hostname} 'ps -p #{instance.pid}'").split("\n")
      if process_report.length == 1 || process_report.last && process_report.last.scan(/(.*#{instance.pid}.*pts\/.*\d\d:\d\d:\d\d (ruby|rdebug))/).flatten.first != process_report.last
        puts "Cleaning Orphan..."
        if self.hostname == instance.hostname
          Sh::bt("rm -r #{ENV["PWD"]}/../tmp_files/#{instance.instance_id}")
        else
          Sh::bt("ssh #{instance.hostname} 'rm -r 140kit_sandbox/code/tmp_files/#{instance.instance_id}'")
        end
        Lock.all(:instance_id => instance.instance_id).destroy
        instance.destroy
      end
    end
    Machine.all.each do |machine|
      files = Sh::storage_bt("ls #{machine.working_path}/code/tmp_files", machine.machine_storage_details)
      files.each do |file|
        Sh::storage_bt("rm -r #{machine.working_path}/code/tmp_files/#{file}", machine.machine_storage_details) if !Instance.all.collect(&:instance_id).include?(file)
      end
    end
    Lock.all(:instance_id.not => Instance.all.collect{|instance| instance.instance_id}).destroy
    self.last_system_check = Time.now
  end
  
  def do_analysis_jobs
    # WARNING: TODO: rest_allowed not implemented yet
    while AnalysisMetadata.unlocked.all(:finished => false, :ready => true).select{|am| ["imported", "live"].include?(am.curation.status)}.length!=0
      metadata = AnalysisMetadata.unlocked.all(:finished => false, :ready => true).select{|am| ["imported", "live"].include?(am.curation.status)}.shuffle.first
      metadata.lock if metadata
      metadata.curation.lock if metadata && metadata.curation
      if !metadata.nil? && metadata.owned_by_me? && !metadata.curation.nil? && metadata.curation.owned?
        $instance.metadata = metadata
        route(metadata)
      end
      metadata.unlock if metadata
      if metadata && metadata.curation.owned? && !AnalysisMetadata.all(:curation_id => metadata.curation.id).collect(&:finished).include?(false)
        metadata.curation.unlock!
      end
    end
    puts "No analysis work to do right now."
  end
  
  def route(metadata)
    puts "Routing Analysis..."
    finished = false
    case metadata.language
    when "ruby"
      Analysis::Dependencies.send(metadata.function)
      vars = [metadata.id]+metadata.run_vars
      puts "#{metadata.function.classify}.run(#{vars.join(", ")})"
      if metadata.curation.tweets_count > 0 && metadata.curation.users_count > 0 && metadata.curation.entities_count > 0  
        finished = metadata.function.classify.constantize.run(*vars) || false
      else
        finished = true
      end
      metadata.finished = finished
      metadata.save
      if finished
        Notification.post("@#{metadata.curation.researcher.user_name}: A job just finished on your #140kit dataset: http://140kit.com/analytics/#{metadata.id}") if metadata.curation.researcher.share_email
        if metadata.researcher.share_email && metadata.curation.researcher.share_email
          Notification.post("@#{metadata.researcher.user_name}: A job you requested on @#{metadata.curation.researcher.user_name}'s dataset just finished on #140kit: http://140kit.com/analytics/#{metadata.id}") 
        elsif metadata.researcher.share_email
          Notification.post("@#{metadata.researcher.user_name}: A job you requested just finished on #140kit: http://140kit.com/analytics/#{metadata.id}") 
        end
      end
    else 
      raise "Language #{metadata.language} is not currently supported for analytical routing!"
    end
  end

end

worker = Worker.new
worker.work
