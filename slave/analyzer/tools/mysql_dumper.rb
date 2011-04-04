class MysqlDumper < AnalysisMetadata
  def self.set_variables(analysis_metadata, curation)
    remaining_variables = []
    analysis_metadata.analytical_offering.variables.each do |variable|
      analytical_offering_variable = AnalyticalOfferingVariable.new
      analytical_offering_variable.analytical_offering_variable_descriptor_id = variable.id
      analytical_offering_variable.analysis_metadata_id = analysis_metadata.id
      case variable.name
      when "curation_id"
        analytical_offering_variable.value = curation.id
        analytical_offering_variable.save
      when "save_path"
        analytical_offering_variable.value = "analytical_results/#{analysis_metadata.function}"
        analytical_offering_variable.save
      else
        remaining_variables << variable
      end
    end
    return remaining_variables
  end

  
  def self.run(curation_id, save_path)
    debugger
    curation = Curation.first({:id => curation_id})
    FilePathing.tmp_folder(curation, self.underscore)
    conditional = Analysis.conditions_to_mysql_query(Analysis.curation_conditional(curation)).strip
    FilePathing.mysqldump(Tweet, conditional)
    FilePathing.mysqldump(User, conditional)
    self.push_tmp_folder(curation.stored_folder_name)
    self.finalize(curation)
  end
  
  def self.clear(am)
    self.remove_permanent_folder(am.curation.stored_folder_name)
    am.destroy
  end
  
  def self.finalize_analysis(curation)
    response = {}
    response[:recipient] = curation.researcher.email
    response[:subject] = "#{curation.researcher.user_name}, your raw SQL data for the #{curation.name} data set is complete."
    response[:message_content] = "Your SQL files are ready for download. You can grab them by visiting the collection's page: <a href=\"http://nutmegunit.com/#{curation.researcher.user_name}/collections/#{curation.id}\">http://nutmegunit.com/#{curation.researcher.user_name}/collections/#{curation.id}</a>."
    return response
  end
  
end
