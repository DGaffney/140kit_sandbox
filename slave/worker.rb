require 'environment'
class Worker < Instance
  
  # attr_accessor :user_account, :username, :password, :start_time, :next_dataset_ends, :queue, :params, :datasets
  attr_accessor :curation
  
  @@words = File.open("analyzer/resources/words.txt", "r").read.split
  @@rest_analytics = ["retweet_graph"]
  
  def initialize
    super
    self.instance_type = "analyzer"
    # @datasets = []
    # @queue = []
    at_exit { do_at_exit }
  end
  
  def do_at_exit
    puts "Exiting."
    unlock_all
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
        sleep(SLEEP_CONSTANT)
      end
    end
  end
  
  def work_routine
    @curation = select_curation
    if !@curation.nil?
      final_counts
      create_jobs
    end
    do_analysis_jobs
  end
  
  def select_curation
    curations = Curation.unlocked.all(:analyzed => false).reject {|c| c.datasets.collect {|d| d.scrape_finished }.include?(false) }
    for curation in curations
      return curation if curation.owned_by_me?
    end
    return nil
  end
  
  def final_counts
    for dataset in @curation.datasets
      dataset.tweets_count = Tweet.count(:dataset_id => dataset.id) if dataset.tweets_count.nil? || dataset.tweets_count==0
      dataset.users_count = User.count(:dataset_id => dataset.id) if dataset.users_count.nil? || dataset.users_count==0
      dataset.save
    end
  end
  
  def create_jobs
    # if the num of finished metadatas == total metadatas and total > 0
    unfinished = AnalysisMetadata.count(:curation_id => @curation.id, :finished => false)
    if unfinished == 0
      total = AnalysisMetadata.count(:curation_id => @curation.id)
      if total > 0
        @curation.analyzed = true
        @curation.save
      else
        puts "Create jobs for dataset #{@curation.id}"
        spawn_analysis_metadatas
      end
    end
  end
  
  def spawn_analysis_metadatas
    analytical_offerings = AnalyticalOffering.all(:enabled => true)
    new_analysis_metadatas = []
    analytical_offerings.each do |analytic|
      #FIXME: no access level checking
      metadata = {  :function => analytic.function,
                    :save_path => analytic.save_path,
                    :curation_id => @curation.id,
                    :rest => analytic.rest }
      new_analysis_metadatas << metadata
    end
    AnalysisMetadata.save_all(new_analysis_metadatas)
  end
  
  def do_analysis_jobs
    # WARNING: TODO: rest_allowed not implemented yet
    while AnalysisMetadata.unlocked.count(:finished => false)!=0
      metadata = AnalysisMetadata.unlocked.first(:finished => false)
      if !metadata.nil? && metadata.owned_by_me?
        route(metadata)
      end
    end
    puts "No analysis work to do right now."
  end
  
  def route(metadata)
    case metadata.language
    when "ruby"
      Analysis::Dependencies.send(metadata.function)
      metadata.function.classify.constantize.run(*metadata.run_vars)
    else 
      raise "Language #{metadata.language} is not currently supported for analytical routing!"
    end
  end
end

worker = Worker.new
worker.work