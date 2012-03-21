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
    import_datasets("importable")
    import_datasets("reimportable")
    archive_datasets
  end
  
  def select_curation(curations_type)
    puts "select_curation..."
    curations = self.send(curations_type+"_curations")
    for curation in curations
      curation.lock
      return curation if curation.owned_by_me?
    end
    return nil
  end
  
  def importable_curations
    Curation.unlocked.all(:status => "needs_import", :previously_imported => false).reject {|c| c.datasets.collect {|d| d.scrape_finished }.include?(false) }.shuffle
  end
  
  def archivable_curations
    Curation.unlocked.all(:status => "needs_import", :previously_imported => true)
  end
  
  def reimportable_curations
    Curation.unlocked.all(:status => "needs_drop")
  end

  def archive_datasets
    @curation = select_curation("archivable")
    return nil if @curation.nil?
    models = [Tweet, User, Entity, Geo, Coordinate, Graph, GraphPoint, Edge, Location, TrendingTopic, Friendship]
    @curation.datasets.each do |dataset|
      storage = Machine.first(:id => dataset.storage_machine_id).machine_storage_details
      models.each do |model|
        offset = 0
        limit = 10000
        results = model.all(:dataset_id => dataset.id, :offset => offset, :limit => limit)
        while !results.empty?
          next_set = results.length==limit ? limit : results.length
          filename = "#{ENV["TMP_PATH"]}/#{dataset.id}_#{offset}_#{offset+next_set}.tsv"
          model.store_to_flat_file(results, filename)
          Sh::mkdir("#{STORAGE["path"]}/raw_catalog/#{model}", storage)
          Sh::compress(filename)
          Sh::store_to_disk(filename, "raw_catalog/#{model}/#{filename}.zip", storage)
          Sh::rm(filename)
          Sh::rm(filename+".zip")
          offset += limit
          results = model.all(:dataset_id => dataset.id, :offset => offset, :limit => limit)
        end
      end
      dataset.status = "dropped"
      dataset.save!
    end
    @curation.status = "dropped"
    @curation.save!
    @curation.unlock
  end
  
  def import_datasets(import_type)
    @curation = select_curation(import_type)
    return nil if @curation.nil?
    model_groups = {"importable" => [Tweet, User, Entity, Geo, Coordinate], "reimportable" => [Tweet, User, Entity, Geo, Coordinate, Graph, GraphPoint, Edge, Location, TrendingTopic, Friendship]}
    models = model_groups[import_type]
    @curation.datasets.each do |dataset|
      storage = Machine.first(:id => dataset.storage_machine_id).machine_storage_details
      models.each do |model|
        files = Sh::storage_ls("raw_catalog/#{model}", storage).select{|x| dataset.id == x.split("_").first.to_i}
        files.each do |file|
          mysql_filename = "mysql_tmp_#{Time.now.to_i}_#{rand(10000)}.sql"
          mysql_file = File.open("#{ENV['TMP_PATH']}/#{mysql_filename}", "w+")
          file_location = Sh::pull_file_from_storage("raw_catalog/#{model.to_s}/#{file}", storage)
          decompressed_files = Sh::decompress(file_location, File.dirname(file_location))
          decompressed_files.each do |decompressed_file|
            header = CSV.open(decompressed_file, "r", :col_sep => "\t", :row_sep => "\0", :quote_char => '"').first
            header_row = header.index("id")
            header[header_row] = "@id" if header_row
            mysql_file.write("load data local infile '#{decompressed_file}' ignore into table #{model.storage_name} fields terminated by '\\t' optionally enclosed by '\"' lines terminated by '\\0' ignore 1 lines (#{header.join(", ")});\n")
            mysql_file.close
            puts "Executing mysql block..."
            config = DataMapper.repository.adapter.options
            puts "mysql -u #{config["user"]} --password='#{config["password"]}' -P #{config["port"]} -h #{config["host"]} #{config["path"].gsub("/", "")} < #{ENV["TMP_PATH"]}/#{mysql_filename} --local-infile=1"
            Sh::sh("mysql -u #{config["user"]} --password='#{config["password"]}' -P #{config["port"]} -h #{config["host"] || "localhost"} #{config["path"].gsub("/", "")} < #{ENV["TMP_PATH"]}/#{mysql_filename} --local-infile=1")
            Sh::storage_rm("raw_catalog/#{model.to_s}/#{file}", storage)
            Sh::rm("#{ENV["TMP_PATH"]}/#{mysql_filename}")
            Sh::rm("#{decompressed_file}")
            Sh::rm("#{file_location}")
          end
        end
      end
      dataset.tweets_count = Tweet.count(:dataset_id => dataset.id) if import_type == "importable"
      dataset.users_count = User.count(:dataset_id => dataset.id) if import_type == "importable"
      dataset.entities_count = Entity.count(:dataset_id => dataset.id) if import_type == "importable"
      dataset.status = "imported"
      dataset.save!
    end
    @curation.status = "imported"
    @curation.previously_imported = true if import_type == "importable"
    @curation.save!
    @curation.unlock
  end
  
end

worker = Importer.new
worker.work

