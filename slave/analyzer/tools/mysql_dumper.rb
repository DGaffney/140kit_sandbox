class MysqlDumper < AnalysisMetadata
  def self.set_variables(analysis_metadata, curation)
    remaining_variables = []
    analysis_metadata.analytical_offering.variables.each do |variable|
      analytical_offering_variable = AnalyticalOfferingVariable.new
      analytical_offering_variable.analytical_offering_variable_descriptor = variable.id
      analytical_offering_variable.analysis_metadata_id = analysis_metadata.id
      case variable.name
      when "curation_id"
        analytical_offering_variable.value = curation.id
        analysis_metadata.analytical_offering_variables
      when "save_path"
        analytical_offering_variable.value = "analytical_results/#{analysis_metadata.function}"
        analysis_metadata.analytical_offering_variables
      else
        remaining_variables << variable
      end
    end
    return remaining_variables
  end
  
  def self.run(curation_id, save_path)
    curation = Curation.find({:id => curation_id})
    conditional = Analysis.conditional(curation).gsub("where", "").gsub("'","\"")
    FilePathing.tmp_folder(curation)
    FilePathing.mysqldump("tweets", conditional)
    FilePathing.mysqldump("users", conditional)
    FilePathing.push_tmp_folder(save_path)
    # recipient = collection.researcher.email
    # subject = "#{collection.researcher.user_name}, your raw data (SQL) for the #{collection.name} data set is complete."
    # message_content = "Your SQL files are ready for download. You can grab them by visiting the collection's page: <a href=\"http://nutmegunit.com/#{collection.researcher.user_name}/collections/#{collection.id}\">http://nutmegunit.com/#{collection.researcher.user_name}/collections/#{collection.id}</a>."
    # send_email(recipient, subject, message_content, collection)
  end
end
