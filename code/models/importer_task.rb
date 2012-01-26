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
    
  def import(importer, to_location=".")
    case type
    when "batch_folder"
      import_batch_folder(importer, to_location)
    when "single_file"
      import_single_file(importer, to_location)
    end
    return self
  end

  def import_batch_folder(importer, to_location=".")
    self.import_files = determine_import_files(to_location)
    self.import_files.each do |import_file_data|
      decompressed_files = Sh::decompress(import_file_data[:original_filename], to_location)
      decompressed_files.each do |import_file|
        Sh::resolve_all_files(import_file).each do |import_file|
          importer.send("import_file_#{File.extname(import_file).gsub(".", "")}", import_file)
          Sh::remove(import_file)
        end
      end
    end
    self.finished = true
    self.unlock
    self.save!
  end
  
  def import_single_file(importer, to_location=".")
    decompressed_files = []
    if Sh::compression_types.include?(File.extname(self.file_location))
      decompressed_files = Sh::decompress(filename, to_location)
    else
      decompressed_files = [self.file_location]
    end
    Sh::resolve_all_files(self.file_location+"/"+import_file).each do |import_file|
      importer.send("import_file_#{File.extname(self.file_location+"/"+import_file).gsub(".", "")}", import_file)
      Sh::remove(self.file_location+"/"+import_file)
    end
  end
  
  def determine_import_files(to_location=".")
    import_files = []
    Sh::sh("ls "+self.file_location).split("\n").each do |import_file|
      filename = self.file_location+"/"+import_file
      if File.file?(filename)
        import_files << {:extension => File.extname(filename), :compressed => Sh::compression_types.include?(File.extname(filename)), :original_filename => filename}
      end
    end
    return import_files
  end

end