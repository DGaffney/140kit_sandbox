class JaccardSoftRetweetCalculator < AnalysisMetadata

  DEFAULT_CHUNK_SIZE = 1000
  MAX_ROW_COUNT_PER_BATCH = 1000
  
  #Results: Frequency Charts of basic data on Tweets and Users per data set
  #!!! Change tolerance to percentile. Calculate all jaccard coefficients that are more than 0.0. Store all of these, then delete ones that are below the given percentile variable. Badass.
  def self.run(curation_id, percentile)
    curation = Curation.first(:id => curation_id)
    analysis_metadata = self.analysis_metadata(curation)
    conditional = Analysis.curation_conditional(curation)
    research_database = connect_to_db("research")
    if research_database.nil?
      self.boot_out
      return nil
    end
    self.generate_jaccard_coefficients(curation, analysis_metadata, conditional, research_database)
    self.calculate_percentile(curation, analysis_metadata, conditional, percentile)
    self.finalize(curation)
  end

  def self.generate_jaccard_coefficients(curation, analysis_metadata, conditional, research_database)
    accounts = research_database.select("select username from account")
    matches = []
    accounts.each do |account|
      limit = DEFAULT_CHUNK_SIZE||1000
      offset = 0
      dataset_tweet_mentions_query = lambda{|account, conditional, limit, offset| "select * from tweets inner join entities on entities.twitter_id = tweets.twitter_id where entities.name = 'user_mention_screen_name' and entities.value = '#{account}' and #{Analysis.conditions_to_mysql_query(conditional).gsub("dataset_id", "entities.dataset_id")} limit #{limit} offset #{offset}"}
      records = DataMapper.repository.adapter.select(dataset_tweet_mentions_query.call(account, conditional, limit, offset))
      while !records.empty?
        records.each do |record|
          account_tweet_query = lambda {|created_at, account| "select content_pipeline.*,twitter_tweet.tweet_id from content_pipeline,twitter_tweet where content_pipeline.published_date is not null and content_pipeline.published_date <= '#{created_at.strftime("%Y-%m-%d %H:%M:%S")}' and twitter_tweet.username = '#{account}' and twitter_tweet.content_pipeline_id = content_pipeline.content_pipeline_id"}
          account_tweets = research_database.select(account_tweet_query.call(record.created_at, account))
          account_tweets.each do |account_tweet|
            coefficient = Jaccard.coefficient(account_tweet.content, record.text)
            if coefficient > 0.0
              matches << {:coefficient => coefficient, :social_flow_tweet_twitter_id => account_tweet.tweet_id, :referencing_tweet_twitter_id => record.twitter_id}              
            end
          end
        end
        offset+=limit
        records = DataMapper.repository.adapter.select(dataset_tweet_mentions_query.call(account, conditional,  limit, offset))
        if matches.length > MAX_ROW_COUNT_PER_BATCH
          JaccardCoefficient.save_all(matches.collect{|match| match.merge(:curation_id => curation.id, :analysis_metadata_id => analysis_metadata.id)})
          matches = []
        end
      end
    end
  end
  
  def self.calculate_percentile(curation, analysis_metadata, conditional, percentile)
    percentile = percentile.to_f
    total = JaccardCoefficient.count(:curation_id => curation.id, :analysis_metadata_id => analysis_metadata.id)
    jaccard_coefficients = []
    limit = DEFAULT_CHUNK_SIZE||1000
    offset = 0
    records = JaccardCoefficient.all(:curation_id => curation.id, :analysis_metadata_id => analysis_metadata.id, :order => :coefficient, :limit => limit, :offset => offset)
    jaccard_coefficients = []
    while !records.empty?
      records.each do |jaccard_coefficient|
        offset+=1
        this_percentile = (1/total.to_f)*(offset.to_f)
        within_percentile = this_percentile>=percentile
        jaccard_coefficients << jaccard_coefficient.attributes.merge(:within_percentile => within_percentile)
      end
      JaccardCoefficient.update_all(jaccard_coefficients)
      jaccard_coefficients = []
      records = JaccardCoefficient.all(:curation_id => curation.id, :analysis_metadata_id => analysis_metadata.id, :order => :coefficient, :limit => limit, :offset => offset)
    end
    JaccardCoefficient.update_all(jaccard_coefficients)
  end

  def self.finalize_analysis(curation)
    response = {}
    return response
  end
end
