class CsvExport < AnalysisMetadata

  DEFAULT_CHUNK_SIZE = 1000

  def self.run(curation_id, model, fields)
    curation = Curation.first({:id => curation_id})
    model = model.classify.constantize rescue nil
    FilePathing.tmp_folder(curation, self.underscore)
    conditional = Analysis.curation_conditional(curation)
    fields = fields.split(",").collect{|x| x.to_s.downcase}.sort
    FilePathing.file_init("#{model}_#{fields.join("_")}.csv")
    self.query_to_csv(model, {:fields => fields}.merge(conditional))
    self.push_tmp_folder(curation.stored_folder_name)
    self.finalize_work(curation)
  end

  def self.query_to_csv(model, conditional, filename="/"+model.storage_name+".csv", path=ENV['TMP_PATH'])
    first = true
    keys = nil
    limit = 1000
    offset = 0
    Sh::mkdir(path)
    csv = CSV.open(path+filename, "w")
    records = model.all({:limit => limit, :offset => offset}.merge(conditional))
    while !records.empty?
      records.each do |row|
        if first
          keys = conditional[:fields]
          puts keys.inspect
          csv << keys
          first = false
        end
        csv << keys.collect{|key| row.attributes[key.to_sym].to_s}
      end
      offset+=limit
      records = model.all({:limit => limit, :offset => offset}.merge(conditional))
    end
    csv.close
  end

  def self.clear(am)
    self.remove_permanent_folder(am.curation.stored_folder_name)
    am.destroy
  end

  def self.finalize_analysis(curation)
    response = {}
    response[:recipient] = curation.researcher.email
    response[:subject] = "#{curation.researcher.user_name}, your raw CSV data for the #{curation.name} data set is complete."
    response[:message_content] = "Your CSV files are ready for download. You can grab them by visiting the collection's page: <a href=\"http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}\">http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}</a>."
    return response
  end
end
