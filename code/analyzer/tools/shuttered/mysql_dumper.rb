class MysqlDumper < AnalysisMetadata
  
  def self.run(curation_id)
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
