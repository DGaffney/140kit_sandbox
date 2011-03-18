class RawCsv < AnalysisMetadata
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
    FilePathing.tmp_folder(curation)
    tweet_query = "select screen_name,location,language,lat,in_reply_to_status_id,created_at,lon,in_reply_to_user_id,text,source,twitter_id,truncated,user_id,in_reply_to_screen_name from tweets "+Analysis.conditional(curation)
    user_query = "select profile_background_image_url,screen_name,location,profile_image_url,utc_offset,contributors_enabled,profile_sidebar_fill_color,url,profile_background_tile,profile_sidebar_border_color,created_at,followers_count,notifications,friends_count,protected,description,geo_enabled,profile_background_color,twitter_id,favourites_count,following,profile_text_color,verified,name,lang,time_zone,statuses_count,profile_link_color from users "+Analysis.conditional(curation)
    FilePathing.file_init("tweets.csv")
    spool_dataset_to_csv(tweet_query, "tweets.csv")
    spool_dataset_to_csv(user_query, "users.csv")
    FilePathing.push_tmp_folder(save_path)
    # recipient = collection.researcher.email
    # subject = "#{collection.researcher.user_name}, your raw CSV data for the #{collection.name} data set is complete."
    # message_content = "Your CSV files are ready for download. You can grab them by visiting the collection's page: <a href=\"http://140kit.com/#{collection.researcher.user_name}/collections/#{collection.id}\">http://140kit.com/#{collection.researcher.user_name}/collections/#{collection.id}</a>."
    # send_email(recipient, subject, message_content, collection)
  end

  def self.spool_dataset_to_csv(query, filename, path=$instance.tmp_path)
    objects = DataMapper.repository(:default).adapter.select(query)
    first_result = objects.fetch_hash
    keys, values = first_result.keys, first_result.values
    num = 1
    FasterCSV.open(path+filename, "w") do |csv|
      csv << keys
      csv << values
      while row = objects.fetch_hash do
        num+=1
        csv << keys.collect{|key| row[key].to_s}
      end
      objects.free
    end
    Database.terminate_spooling
  end
end
