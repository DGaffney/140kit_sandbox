class ImporterTask
  include DataMapper::Resource
  property :id, Serial
  property :file_location, String
  property :type, String, :unique_index => [:unique_importer_task]
  property :researcher_id, Integer, :unique_index => [:unique_importer_task], :default => 0
  property :dataset_id, Integer
  property :finished, Boolean, :default => false
  belongs_to :dataset
  belongs_to :researcher

  attr_accessor :current_file, :import_files
    
  def import(to_location=".")
    case type
    when "batch_folder"
      import_batch_folder(to_location)
    when "single_file"
      import_single_file(to_location)
    end
    return self
  end

  def import_batch_folder(to_location=".")
    self.import_files = determine_import_files(to_location)
    self.import_files.each do |import_file_data|
      decompressed_files = Sh::decompress(import_file_data[:original_filename], to_location)
      decompressed_files.each do |import_file|
        Sh::resolve_all_files(import_file).each do |import_file|
          self.send("import_file_#{File.extname(import_file).gsub(".", "")}", import_file)
          # Sh::remove(import_file)
        end
      end
    end
    self.finished = true
    self.unlock
    self.save!
  end
  
  def import_single_file(to_location=".")
    decompressed_files = []
    if Sh::compression_types.include?(File.extname(self.file_location))
      decompressed_files = Sh::decompress(filename, to_location)
    else
      decompressed_files = [self.file_location]
    end
    self.send("import_file_#{File.extname(self.file_location).gsub(".", "")}")
  end
  
  def determine_import_files(to_location=".")
    import_files = []
    Sh::sh("ls "+self.file_location).split("\n").each do |import_file|
      filename = self.file_location
      if File.file?(filename)
        import_files << {:extension => File.extname(filename), :compressed => Sh::compression_types.include?(File.extname(filename)), :original_filename => filename}
      end
    end
    return import_files
  end

  def import_file_tsv
    return "Not a valid path: #{file_location}" if !File.exists?(file_location)
    mysql_filename = "mysql_tmp_#{Time.now.to_i}_#{rand(10000)}.sql"
    mysql_file = File.open(mysql_filename, "w+")
    header = CSV.open(file_location, :col_sep => "\t", :row_sep => "\0", :quote_char => '"').first
    header_row = header.index("id")
    header[header_row] = "@id" if header_row
    model = map_to_model(header)
    return "Not a valid model set: #{model.inspect}" if model.nil?
    if header.include?("dataset_id")
      puts "load data infile '#{file_location}' ignore into table #{model.storage_name} fields terminated by '\\t' optionally enclosed by '\"' lines terminated by '\\0' ignore 1 lines (#{header.join(", ")}) set dataset_id = '#{self.dataset_id}';\n"
      mysql_file.write("load data infile '#{file_location}' ignore into table #{model.storage_name} fields terminated by '\\t' optionally enclosed by '\"' lines terminated by '\\0' ignore 1 lines (#{header.join(", ")}) set dataset_id = '#{self.dataset_id}';\n")
    else
      mysql_file.write("load data infile '#{file_location}' ignore into table #{model.storage_name} fields terminated by '\\t' optionally enclosed by '\"' lines terminated by '\\0' ignore 1 lines (#{header.join(", ")});\n")
    end
    start = Time.now
    mysql_file.close
    puts "Executing mysql block..."
    config = DataMapper.repository.adapter.options
    puts "mysql -u #{config["user"]} --password='#{config["password"]}' -P #{config["port"]} -h #{config["host"]} #{config["path"].gsub("/", "")} < #{mysql_filename}"
    Sh::sh("mysql -u #{config["user"]} --password='#{config["password"]}' -P #{config["port"]} -h #{config["host"]} #{config["path"].gsub("/", "")} < #{mysql_filename}")
    Sh::remove(mysql_filename)
    self.finished = true
    self.save!
    puts "Executed mysql block (#{Time.now-start} seconds)."
  end
  
  def map_to_model(fields)
    tables = {}
    DataMapper.repository.adapter.select("show tables").each do |table|
      tables[table] = DataMapper.repository.adapter.select("show fields from #{table}").collect{|f| f.field}
    end
    result = [] 
    tables.values.collect{|t| result=t if (result&fields).length < (t&fields).length}
    return tables.invert[result] && tables.invert[result].classify.constantize || nil
  end
end
