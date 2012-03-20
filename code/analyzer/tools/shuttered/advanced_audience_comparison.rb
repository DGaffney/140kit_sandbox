class AdvancedAudienceComparison < AnalysisMetadata

  DEFAULT_CHUNK_SIZE = 10000

  def self.set_variables(analysis_metadata, analytical_offering_variable, curation)
    case analytical_offering_variable.function
    when "start_range"
      return 1
    when "end_range"
      return lambda {|accounts| accounts.length}
    end
  end
  
  #Results: Frequency Charts of basic data on Tweets and Users per data set
  def self.run(curation_id, start_range, end_range)
    

    dir = "/home/dgaffney/SocialFlow-Twitter-Consumer/results/cnn_foxnews_ajenglish_bbcnews_nytimes_theeconomist_6_4"
    all_files = Sh::sh("ls #{dir}").split("\n").collect{|x| x.downcase.split("_").sort.join("_")}
    left_to_do = []
    accts = ["cnn", "foxnews", "ajenglish", "bbcnews", "nytimes", "theeconomist"]
    accts.all_combinations.each do |combo|
      left_to_do << combo.sort.join("_") if !all_files.include?(combo.sort.join("_"))
    end
    
    

    curation = Curation.first(:id => curation_id)
    # self.validates([Struct::Condition.new("all_datasets_are_audience_profiles", lambda{|datasets| datasets.collect{|dataset| dataset.scrape_type=="audience_profile"}.compact.length==1}, curation.datasets)], self.analysis_metadata(curation))
    # self.validates([Struct::Condition.new("storage_device_is_mysql", lambda{DataMapper.repository.adapter.options["adapter"]=="mysql"})], self.analysis_metadata(curation))    
    accounts = curation.datasets.collect{|dataset| User.first(:screen_name => dataset.params.split(",").first)}
    end_range = end_range.class == Proc ? end_range.call(accounts) : end_range
    accounts.all_combinations(start_range..end_range).each do |combination|
      account_names = combination.collect{|u| u.screen_name}
      if left_to_do.include?(account_names.collect{|n| n.downcase}.sort.join("_"))
        FilePathing.tmp_folder(curation, self.underscore+"_#{account_names.join("_")}")
        path=ENV['TMP_PATH']
        follower_ids = DataMapper.repository.adapter.select(self.proper_followers_select(combination)+self.proper_followers_conditional(combination))
        AdvancedHistogram.generate_sequential_tweet_graphs(curation, path, {:user_id => follower_ids}, AdvancedAudienceComparison, account_names.join("_"))
        AdvancedHistogram.generate_sequential_user_graphs(curation, path, {:twitter_id => follower_ids}, AdvancedAudienceComparison, account_names.join("_"))
        AdvancedHistogram.generate_tweet_avg_sum_graphs(curation, path, {:user_id => follower_ids}, AdvancedAudienceComparison, account_names.join("_"))
        AdvancedHistogram.generate_user_avg_sum_graphs(curation, path, {:twitter_id => follower_ids}, AdvancedAudienceComparison, account_names.join("_"))
        self.push_tmp_folder(curation.stored_folder_name+"/#{account_names.join("_")}")
      end
    end
    self.finalize(curation)
  end

  def self.proper_followers_select(combination)
    query = ""
    first = true
    combination.each do |acct|
      if first
        query+="select #{acct.screen_name}.follower_user_id  FROM friendships AS #{acct.screen_name} "
        first = false
      else
        query+=" JOIN friendships AS #{acct.screen_name} ON #{combination.first.screen_name}.follower_user_id=#{acct.screen_name}.follower_user_id "
      end
    end
    return query
  end

  def self.proper_followers_conditional(combination)
    conditional = "where "+combination.collect{|acct| "#{acct.screen_name}.followed_user_id=#{acct.twitter_id} and "}.flatten.to_s.chop.chop.chop.chop
    return conditional
  end

  def self.finalize_analysis(curation)
    response = {}
    response[:recipient] = curation.researcher.email
    response[:subject] = "#{curation.researcher.user_name}, the raw Graph data for the basic histograms in the \"#{curation.name}\" data set is complete."
    response[:message_content] = "Your CSV files are ready for download. You can grab them by visiting the collection's page: <a href=\"http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}\">http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}</a>."
    return response
  end
end
