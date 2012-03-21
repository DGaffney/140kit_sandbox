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
    #we can't import/archive until all workers have let go of the dataset, so we need to check for unlocked status of all analysis metadatas... I think. something is occuring where graphs are getting deleted/not getting re-imported.
    puts "select_curation..."
    curations = self.send(curations_type+"_curations")
    for curation in curations
      curation.lock if curation.all_analysis_metadatas_clear?
      return curation if curation.owned_by_me?
    end
    return nil
  end
  
  def importable_curations
    Curation.unlocked.all(:status => "needs_import", :previously_imported => false).reject {|c| c.datasets.collect {|d| d.scrape_finished }.include?(false) }.shuffle
  end
  
  def archivable_curations
    Curation.unlocked.all(:status => "needs_drop", :previously_imported => true)
  end
  
  def reimportable_curations
    Curation.unlocked.all(:status => "needs_import", :previously_imported => true)
  end

  def archive_datasets
    @curation = select_curation("archivable")
    return nil if @curation.nil?
    primary_models = [Tweet, User, Entity, Geo, Coordinate, Location, TrendingTopic, Friendship]
    storage = Machine.first(:id => @curation.datasets.first.storage_machine_id).machine_storage_details
    config = DataMapper.repository.adapter.options
    @curation.datasets.each do |dataset|
      primary_models.each do |model|
        offset = 0
        limit = 100
        finished = false
        remaining = model.count(:dataset_id => dataset.id)
        while !finished
          next_set = remaining>limit ? limit : remaining
          remaining = (remaining-limit)>0 ? remaining-limit : 0        
          puts "Archiving #{offset} - #{offset+next_set} (#{model})"
          path = ENV["TMP_PATH"]
          Sh::mkdir(path)
          filename = "#{@curation.id}_#{offset}_#{offset+next_set}"
          mysql_section = "mysql -u #{config["user"]} --password='#{config["password"]}' -P #{config["port"]} -h #{config["host"]} #{config["path"].gsub("/", "")} -B -e "
          mysql_statement = "\"select * from #{model.storage_name} where dataset_id = #{dataset.id} limit #{limit};\""
          file_push = " | sed -n -e 's/^\"//;s/\"$//;s/\",\"/ /;s/\",\"/\\n/;P' > #{path}#{filename}.tsv"
          command = "#{mysql_section}#{mysql_statement}#{file_push}"
          Sh::sh(command)
          Sh::compress(path+filename+".tsv")
          Sh::mkdir("#{STORAGE["path"]}/raw_catalog/#{model}", storage)
          Sh::store_to_disk(path+filename+".tsv.zip", "raw_catalog/#{model}/#{filename}.tsv.zip", storage)
          Sh::rm(path+filename+".tsv")
          Sh::rm(path+filename+".tsv.zip")
          DataMapper.repository.adapter.execute("delete quick from #{model.storage_name} where dataset_id = #{dataset.id} order by id limit #{limit}")
          offset += limit
          finished = true if remaining == 0
        end
      end
      dataset.status = "dropped"
      dataset.save!
    end
    secondary_models = [Graph, GraphPoint, Edge]
    secondary_models.each do |model|
      offset = 0
      limit = 100
      remaining = model.count(:curation_id => @curation.id)
      finished = false
      while remaining != 0
        next_set = remaining>limit ? limit : remaining
        remaining = (remaining-limit)>0 ? remaining-limit : 0        
        puts "Archiving #{offset} - #{offset+next_set} (#{model})"
        path = ENV["TMP_PATH"]
        Sh::mkdir(path)
        filename = "#{@curation.id}_#{offset}_#{offset+next_set}"
        mysql_section = "mysql -u #{config["user"]} --password='#{config["password"]}' -P #{config["port"]} -h #{config["host"]} #{config["path"].gsub("/", "")} -B -e "
        mysql_statement = "\"select * from #{model.storage_name} where curation_id = #{@curation.id} limit #{limit} offset #{offset};\""
        file_push = " | sed -n -e 's/^\"//;s/\"$//;s/\",\"/ /;s/\",\"/\\n/;P' > #{path}#{filename}.tsv"
        command = "#{mysql_section}#{mysql_statement}#{file_push}"
        Sh::sh(command)
        Sh::compress(path+filename+".tsv")
        Sh::mkdir("#{STORAGE["path"]}/raw_catalog/#{model}", storage)
        Sh::store_to_disk(path+filename+".tsv.zip", "raw_catalog/#{model}/#{filename}.tsv.zip", storage)
        Sh::rm(path+filename+".tsv")
        Sh::rm(path+filename+".tsv.zip")
        DataMapper.repository.adapter.execute("delete quick from #{model.storage_name} where curation_id = #{@curation.id} order by id limit #{limit}")
        offset += limit
        finished = true if remaining != 0
      end
    end
    @curation.status = "dropped"
    @curation.save!
    @curation.unlock
  end
  
  def import_datasets(import_type)
    @curation = select_curation(import_type)
    return nil if @curation.nil?
    models = [Tweet, User, Entity, Geo, Coordinate, Location, TrendingTopic, Friendship]
    optional_enclosed_by = import_type == "importable" ? "optionally enclosed by '\"'" : ""
    line_separator_escaped = import_type == "importable" ? "\\0" : "\\n"
    line_separator = import_type == "importable" ? "\0" : "\n"
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
            header = CSV.open(decompressed_file, "r", :col_sep => "\t", :row_sep => line_separator, :quote_char => '"').first
            # header_row = header.index("id")
            # header[header_row] = "@id" if header_row
            mysql_file.write("load data local infile '#{decompressed_file}' ignore into table #{model.storage_name} fields terminated by '\\t' #{optional_enclosed_by} lines terminated by '#{line_separator_escaped}' ignore 1 lines (#{header.join(", ")});\n")
            mysql_file.close
            puts "Executing mysql block..."
            config = DataMapper.repository.adapter.options
            puts "mysql -u #{config["user"]} --password='#{config["password"]}' -P #{config["port"]} -h #{config["host"]} #{config["path"].gsub("/", "")} < #{ENV["TMP_PATH"]}/#{mysql_filename} --local-infile=1"
            Sh::sh("mysql -u #{config["user"]} --password='#{config["password"]}' -P #{config["port"]} -h #{config["host"] || "localhost"} #{config["path"].gsub("/", "")} < #{ENV["TMP_PATH"]}/#{mysql_filename} --local-infile=1")
            # Sh::storage_rm("raw_catalog/#{model.to_s}/#{file}", storage)
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
    models = [Graph, GraphPoint, Edge]
    if import_type == "reimportable"
      storage = Machine.first(:id => @curation.datasets.first.storage_machine_id).machine_storage_details
      models.each do |model|
        files = Sh::storage_ls("raw_catalog/#{model}", storage).select{|x| @curation.id == x.split("_").first.to_i}
        files.each do |file|
          mysql_filename = "mysql_tmp_#{Time.now.to_i}_#{rand(10000)}.sql"
          mysql_file = File.open("#{ENV['TMP_PATH']}/#{mysql_filename}", "w+")
          file_location = Sh::pull_file_from_storage("raw_catalog/#{model.to_s}/#{file}", storage)
          decompressed_files = Sh::decompress(file_location, File.dirname(file_location))
          decompressed_files.each do |decompressed_file|
            header = CSV.open(decompressed_file, "r", :col_sep => "\t", :row_sep => line_separator, :quote_char => '"').first
            # header_row = header.index("id")
            # header[header_row] = "@id" if header_row
            mysql_file.write("load data local infile '#{decompressed_file}' ignore into table #{model.storage_name} fields terminated by '\\t' #{optional_enclosed_by} lines terminated by '#{line_separator_escaped}' ignore 1 lines (#{header.join(", ")});\n")
            mysql_file.close
            puts "Executing mysql block..."
            config = DataMapper.repository.adapter.options
            puts "mysql -u #{config["user"]} --password='#{config["password"]}' -P #{config["port"]} -h #{config["host"]} #{config["path"].gsub("/", "")} < #{ENV["TMP_PATH"]}/#{mysql_filename} --local-infile=1"
            Sh::sh("mysql -u #{config["user"]} --password='#{config["password"]}' -P #{config["port"]} -h #{config["host"] || "localhost"} #{config["path"].gsub("/", "")} < #{ENV["TMP_PATH"]}/#{mysql_filename} --local-infile=1")
            # Sh::storage_rm("raw_catalog/#{model.to_s}/#{file}", storage)
            Sh::rm("#{ENV["TMP_PATH"]}/#{mysql_filename}")
            Sh::rm("#{decompressed_file}")
            Sh::rm("#{file_location}")
          end
        end
      end
    end
    @curation.status = "imported"
    @curation.previously_imported = true if import_type == "importable"
    @curation.save!
    @curation.unlock
  end
  
end

worker = Importer.new
worker.work

