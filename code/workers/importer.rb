load File.dirname(__FILE__)+'/../environment.rb'
load File.dirname(__FILE__)+'/../analyzer/analysis.rb'
class Importer < Instance
  
  # attr_accessor :user_account, :username, :password, :start_time, :next_dataset_ends, :queue, :params, :datasets
  attr_accessor :curation
  
  @@words = File.open(File.dirname(__FILE__)+"/../analyzer/resources/words.txt", "r").read.split
  @@rest_analytics = ["retweet_graph"]
  
  def initialize
    super
    self.instance_type = "importer"
    self.save
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
        sleep(SLEEP_CONSTANT)
      end
    end
  end
  
  def work_routine
    @curation = select_curation
    if @curation
      import_datasets_to_database
      flag_curation
    end
  end
  
  def select_curation
    puts "select_curation..."
    curations = Curation.unlocked.all(:status => "needs_import").reject {|c| c.datasets.collect {|d| d.scrape_finished }.include?(false) }.shuffle
    for curation in curations
      curation.lock
      return curation if curation.owned_by_me?
    end
    return nil
  end

  def import_datasets_to_database
    debugger
    # @curation = Curation.first
    # Sh::mkdir(ENV["TMP_PATH"], "local")
    # dataset_ids = @curation.datasets.collect{|x| x.id}
    # models = [Tweet, User, Entity, Geo, Coordinate]
    # models.each do |model|
    #   files = Sh::storage_ls(model.to_s).select{|x| dataset_ids.include?(x[0].to_i)}
    #   files.each do |file|
    #     mysql_filename = "mysql_tmp_#{Time.now.to_i}_#{rand(10000)}.sql"
    #     mysql_file = File.open("#{ENV['TMP_PATH']}/#{mysql_filename}", "w+")
    #     file_location = Sh::pull_file_from_storage("#{model.to_s}/#{file}")#ENV["TMP_PATH"]+"/"+file
    #     header = CSV.open(file_location, "r", :col_sep => "\t", :row_sep => "\0", :quote_char => '"').first
    #     header_row = header.index("id")
    #     header[header_row] = "@id" if header_row
    #     mysql_file.write("load data local infile '#{file_location}' ignore into table #{model.storage_name} fields terminated by '\\t' optionally enclosed by '\"' lines terminated by '\\0' ignore 1 lines (#{header.join(", ")});\n")
    #     mysql_file.close
    #     puts "Executing mysql block..."
    #     config = DataMapper.repository.adapter.options
    #     puts "mysql -u #{config["user"]} --password='#{config["password"]}' -P #{config["port"]} -h #{config["host"]} #{config["path"].gsub("/", "")} < #{ENV["TMP_PATH"]}/#{mysql_filename} --local-infile=1"
    #     Sh::sh("sudo mysql -u #{config["user"]} --password='#{config["password"]}' -P #{config["port"]} -h #{config["host"] || "localhost"} #{config["path"].gsub("/", "")} < #{ENV["TMP_PATH"]}/#{mysql_filename} --local-infile=1")
    #     Sh::remove("#{ENV["TMP_PATH"]}/#{mysql_filename}")
    #     Sh::remove("#{file_location}")
    #   end
    # end
    # self.finished = true
    # self.save!
    # @curation.status = "live"
    # @curation.save!
    # @curation.unlock
  end
  
end

worker = Importer.new
worker.work

