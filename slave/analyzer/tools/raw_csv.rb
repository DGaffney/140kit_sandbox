class RawCsv < AnalysisMetadata
  
  DEFAULT_CHUNK_SIZE = 1000
  
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
    curation = Curation.first({:id => curation_id})
    FilePathing.tmp_folder(curation)
    conditional = Analysis.curation_conditional(curation)
    tweet_fields = ["screen_name", "location", "language", "lat", "in_reply_to_status_id", "created_at", "lon", "in_reply_to_user_id", "text", "source", "retweeted", "retweet_count", "twitter_id", "truncated", "user_id", "in_reply_to_screen_name", "dataset_id"]
    user_fields = ["profile_background_image_url", "screen_name", "location", "profile_image_url", "utc_offset", "contributors_enabled", "profile_sidebar_fill_color", "url", "profile_background_tile", "profile_sidebar_border_color", "created_at", "followers_count", "notifications", "friends_count", "protected", "description", "geo_enabled", "profile_background_color", "twitter_id", "favourites_count", "following", "profile_text_color", "verified", "name", "lang", "time_zone", "statuses_count", "profile_link_color", "dataset_id"]
    FilePathing.file_init("tweets.csv")
    self.chunked_query_to_csv(Tweet, {:fields => tweet_fields}.merge(conditional))
    self.chunked_query_to_csv(User, {:fields => tweet_fields}.merge(conditional))
    self.push_tmp_folder(curation.stored_folder_name)
    # recipient = collection.researcher.email
    # subject = "#{collection.researcher.user_name}, your raw CSV data for the #{collection.name} data set is complete."
    # message_content = "Your CSV files are ready for download. You can grab them by visiting the collection's page: <a href=\"http://140kit.com/#{collection.researcher.user_name}/collections/#{collection.id}\">http://140kit.com/#{collection.researcher.user_name}/collections/#{collection.id}</a>."
    # send_email(recipient, subject, message_content, collection)
  end

  def self.query_to_csv(model, conditional, filename="/"+model.underscore+".csv", path=ENV['TMP_PATH'])
    first = true
    keys = nil
    Sh::mkdir(path+"/raw_csv")
    FasterCSV.open(path+"/raw_csv"+filename, "w") do |csv|
      model.all(conditional).chunks(DEFAULT_CHUNK_SIZE).each do |chunk|
        if first
          keys = chunk.first.attributes.keys.collect{|k| k.to_s}
          puts keys.inspect
          csv << keys
          first = false
        end
        chunk.each do |row|
          csv << keys.collect{|key| row.attributes[key.to_sym].to_s}
        end
      end
    end
  end
end
