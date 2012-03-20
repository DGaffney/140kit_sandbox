class AdvancedHistogram < AnalysisMetadata

  DEFAULT_CHUNK_SIZE = 10000
  
  #Results: Frequency Charts of basic data on Tweets and Users per data set
  def self.run(analysis_metadata_id)
    analysis_metadata = AnalysisMetadata.first(:id => analysis_metadata_id)
    curation = analysis_metadata.curation
    FilePathing.tmp_folder(curation, self.underscore)
    self.generate_sequential_tweet_graphs(curation)
    self.generate_sequential_user_graphs(curation)
    self.generate_user_avg_sum_graphs(curation)
    self.finalize(curation)
  end

  def self.generate_sequential_tweet_graphs(curation, additional_query={}, analytic=self, title_suffix="")
    title_suffix = title_suffix.empty? ? "" : "_#{title_suffix}"
    sequential_tweet_graphs = []
    #can be run sequentially
    sequential_tweet_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "hashtag_count|retweet_count#{title_suffix}")
    sequential_tweet_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "link_count|retweet_count#{title_suffix}")
    sequential_tweet_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "mention_count|retweet_count#{title_suffix}")
    sequential_tweet_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "entity_count|retweet_count#{title_suffix}")
    sequential_tweet_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "source_retweet_counts#{title_suffix}")
    sequential_tweet_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "source_link_count#{title_suffix}")
    sequential_tweet_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "source_mention_count#{title_suffix}")
    sequential_tweet_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "source_entity_count#{title_suffix}")
    sequential_tweet_graph_initialized = sequential_tweet_graphs.collect{|graph| true}
    conditional = Analysis.curation_conditional(curation).merge(additional_query)
    full_entity_matched_query = lambda{|conditional, limit, offset| 
      "select tweets.*,count(distinct entities_l.id) as links_count,count(distinct entities_m.id) as mentions_count,count(distinct entities_h.id) as hashtag_count,count(distinct entities_a.id) as all_entities_count
      from tweets 
      left join entities as entities_l on entities_l.twitter_id = tweets.twitter_id and entities_l.name='url' 
      left join entities as entities_m on entities_m.twitter_id = tweets.twitter_id and entities_m.name='user_mention_screen_name' 
      left join entities as entities_h on entities_h.twitter_id = tweets.twitter_id and entities_h.name='hashtag'
      left join entities as entities_a on entities_a.twitter_id = tweets.twitter_id and entities_a.name in ('url', 'user_mention_screen_name', 'hashtag')
      #{Analysis.conditions_to_mysql_query(conditional).gsub("dataset_id","tweets.dataset_id")} group by tweets.id limit #{limit} offset #{offset}"
    }
    limit = DEFAULT_CHUNK_SIZE
    offset = 0
    records = DataMapper.repository.adapter.select(full_entity_matched_query.call(conditional, limit, offset))
    while !records.empty?
      sequential_tweet_graphs.each do |sequential_tweet_graph|
        case sequential_tweet_graph.title
        when "hashtag_count|retweet_count"
          GraphPoint.save_all(records.collect{|record| {:label => record.hashtag_count, :value => record.retweet_count, :graph_id => sequential_tweet_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "link_count|retweet_count"
          GraphPoint.save_all(records.collect{|record| {:label => record.links_count, :value => record.retweet_count, :graph_id => sequential_tweet_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "mention_count|retweet_count"
          GraphPoint.save_all(records.collect{|record| {:label => record.mentions_count, :value => record.retweet_count, :graph_id => sequential_tweet_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "entity_count|retweet_count"
          GraphPoint.save_all(records.collect{|record| {:label => record.all_entities_count, :value => record.retweet_count, :graph_id => sequential_tweet_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "source_retweet_counts"
          GraphPoint.save_all(records.collect{|record| {:label => record.source, :value => record.retweet_count, :graph_id => sequential_tweet_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "source_link_count"
          GraphPoint.save_all(records.collect{|record| {:label => record.source, :value => record.links_count, :graph_id => sequential_tweet_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "source_mention_count"
          GraphPoint.save_all(records.collect{|record| {:label => record.source, :value => record.mentions_count, :graph_id => sequential_tweet_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "source_entity_count"
          GraphPoint.save_all(records.collect{|record| {:label => record.source, :value => record.all_entities_count, :graph_id => sequential_tweet_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        end
      end
      offset+=limit
      records = DataMapper.repository.adapter.select(full_entity_matched_query.call(conditional, limit, offset))
    end
  end

  def self.generate_tweet_avg_sum_graphs(curation, additional_query={}, analytic=self, title_suffix="")
    limit = DEFAULT_CHUNK_SIZE
    conditional = Analysis.curation_conditional(curation)
    FilePathing.tmp_folder(curation, analytic.underscore)
    #need to be run on their own
    tweets_per_minute = Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "tweets|minute#{title_suffix}")
    retweets_per_minute = Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "retweets|minute#{title_suffix}")
    time_based_tweet_query = ""
    case DataMapper.repository.adapter.options["adapter"]
    when "mysql"
      time_based_tweet_query = lambda{|limit, offset| "select count(*) as tweet_count, sum(retweet_count) as retweet_count, date_format(created_at, '%Y-%m-%d %H:%i') as created_at from tweets #{Analysis.conditions_to_mysql_query(conditional).gsub("dataset_id","tweets.dataset_id")} group by date_format(created_at, '%Y-%m-%d %H:%i') limit #{limit} offset #{offset};"}
    when "sqlite3"
      time_based_tweet_query = lambda{|limit, offset| "select count(*) as tweet_count, sum(retweet_count) as retweet_count, strftime('%Y-%m-%d %H:%M', created_at) as created_at from tweets #{Analysis.conditions_to_mysql_query(conditional).gsub("dataset_id","tweets.dataset_id")} group by strftime('%Y-%m-%d %H:%M', created_at) limit #{limit} offset #{offset};"}
    end
    offset = 0
    records = DataMapper.repository.adapter.select(time_based_tweet_query.call(limit, offset))
    while !records.empty?
      GraphPoint.save_all(records.collect{|record| {:label => record.created_at, :value => record.tweet_count, :graph_id => tweets_per_minute.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
      GraphPoint.save_all(records.collect{|record| {:label => record.created_at, :value => record.retweet_count, :graph_id => retweets_per_minute.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
      offset += limit
      records = DataMapper.repository.adapter.select(time_based_tweet_query.call(limit, offset))
    end
  end
  
  def self.generate_sequential_user_graphs(curation, additional_query={}, analytic=self, title_suffix="")
    limit = DEFAULT_CHUNK_SIZE
    conditional = Analysis.curation_conditional(curation).merge(additional_query)
    FilePathing.tmp_folder(curation, analytic.underscore)    
    #can be run sequentially
    sequential_user_graphs = []
    sequential_user_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "followers_count|friends_count#{title_suffix}")
    sequential_user_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "followers_count|statuses_count#{title_suffix}")
    sequential_user_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "friends_count|statuses_count#{title_suffix}")
    sequential_user_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "followers_per_day#{title_suffix}")
    sequential_user_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "friends_per_day#{title_suffix}")
    sequential_user_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "statuses_per_day#{title_suffix}")
    sequential_user_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "avg_followers_per_day|avg_friends_per_day#{title_suffix}")
    sequential_user_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "avg_followers_per_day|avg_statuses_per_day#{title_suffix}")
    sequential_user_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "avg_friends_per_day|avg_statuses_per_day#{title_suffix}")
    offset = 0
    records = User.all(conditional.merge({:limit => limit, :offset => offset}))
    while !records.empty?
      sequential_user_graphs.each do |sequential_user_graph|
        case sequential_user_graph.title
        when "followers_count|friends_count"
          GraphPoint.save_all(records.collect{|record| {:label => record.followers_count, :value => record.friends_count, :graph_id => sequential_user_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "followers_count|statuses_count"
          GraphPoint.save_all(records.collect{|record| {:label => record.followers_count, :value => record.statuses_count, :graph_id => sequential_user_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "friends_count|statuses_count"
          GraphPoint.save_all(records.collect{|record| {:label => record.friends_count, :value => record.statuses_count, :graph_id => sequential_user_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "followers_|day"
          GraphPoint.save_all(records.collect{|record| {:label => record.twitter_id, :value => record.followers_count.to_f/((Time.now-record.created_at).to_f/86400.0), :graph_id => sequential_user_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "friends_|day"
          GraphPoint.save_all(records.collect{|record| {:label => record.twitter_id, :value => record.friends_count.to_f/((Time.now-record.created_at).to_f/86400.0), :graph_id => sequential_user_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "statuses_|day"
          GraphPoint.save_all(records.collect{|record| {:label => record.twitter_id, :value => record.statuses_count.to_f/((Time.now-record.created_at).to_f/86400.0), :graph_id => sequential_user_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "avg_followers_per_day|avg_friends_per_day"
          GraphPoint.save_all(records.collect{|record| {:label => record.followers_count.to_f/((Time.now-record.created_at).to_f/86400.0), :value => record.friends_count.to_f/((Time.now-record.created_at).to_f/86400.0), :graph_id => sequential_user_graph.id, :analysis_metadata_id =>  analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "avg_followers_per_day|avg_statuses_per_day"
          GraphPoint.save_all(records.collect{|record| {:label => record.followers_count.to_f/((Time.now-record.created_at)/86400.0), :value => record.statuses_count.to_f/((Time.now-record.created_at).to_f/86400.0), :graph_id => sequential_user_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "avg_friends_per_day|avg_statuses_per_day"
          GraphPoint.save_all(records.collect{|record| {:label => record.friends_count.to_f/((Time.now-record.created_at).to_f/86400.0), :value => record.statuses_count.to_f/((Time.now-record.created_at).to_f/86400.0), :graph_id => sequential_user_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        end
      end
      offset += limit
      records = User.all(conditional.merge({:limit => limit, :offset => offset}))
    end
  end
  
  def self.generate_user_avg_sum_graphs(curation, additional_query={}, analytic=self, title_suffix="")
    limit = DEFAULT_CHUNK_SIZE
    conditional = Analysis.curation_conditional(curation).merge(additional_query)
    FilePathing.tmp_folder(curation, analytic.underscore)
    #need to be run on their own
    user_avg_sum_graphs = []
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "location|avg_followers_counts#{title_suffix}")
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "location|avg_friends_counts#{title_suffix}")
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "location|avg_statuses_counts#{title_suffix}")
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "location|sum_followers_counts#{title_suffix}")
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "location|sum_friends_counts#{title_suffix}")
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "location|sum_statuses_counts#{title_suffix}")
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "avg_followers_counts|avg_friends_counts#{title_suffix}")
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "avg_followers_counts|avg_statuses_counts#{title_suffix}")
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "avg_friends_counts|avg_statuses_counts#{title_suffix}")
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "sum_followers_counts|sum_friends_counts#{title_suffix}")
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "sum_followers_counts|sum_statuses_counts#{title_suffix}")
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "sum_friends_counts|sum_statuses_counts#{title_suffix}")
    location_grouped_user_query = lambda{|limit, offset| "select avg(followers_count) as avg_followers_count,avg(friends_count) as avg_friends_count,avg(statuses_count) as avg_statuses_count,sum(followers_count) as sum_followers_count,sum(friends_count) as sum_friends_count,sum(statuses_count) as sum_statuses_count,location from users #{Analysis.conditions_to_mysql_query(conditional).gsub("dataset_id","tweets.dataset_id")} group by location limit #{limit} offset #{offset}"}
    offset = 0
    records = DataMapper.repository.adapter.select(location_grouped_user_query.call(limit, offset))
    while !records.empty?
      user_avg_sum_graphs.each do |user_avg_sum_graph|
        case user_avg_sum_graph.title
        when "location|avg_followers_counts"
          GraphPoint.save_all(records.collect{|record| {:label => record.location, :value => record.avg_followers_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "location|avg_friends_counts"
          GraphPoint.save_all(records.collect{|record| {:label => record.location, :value => record.avg_friends_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "location|avg_statuses_counts"
          GraphPoint.save_all(records.collect{|record| {:label => record.location, :value => record.avg_statuses_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "location|sum_followers_counts"
          GraphPoint.save_all(records.collect{|record| {:label => record.location, :value => record.sum_followers_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "location|sum_friends_counts"
          GraphPoint.save_all(records.collect{|record| {:label => record.location, :value => record.sum_followers_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "location|sum_statuses_counts"
          GraphPoint.save_all(records.collect{|record| {:label => record.location, :value => record.sum_statuses_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "avg_followers_counts|avg_friends_counts"
          GraphPoint.save_all(records.collect{|record| {:label => record.avg_followers_count, :value => record.avg_friends_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "avg_followers_counts|avg_statuses_counts"
          GraphPoint.save_all(records.collect{|record| {:label => record.avg_followers_count, :value => record.avg_statuses_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "avg_friends_counts|avg_statuses_counts"
          GraphPoint.save_all(records.collect{|record| {:label => record.avg_friends_count, :value => record.avg_statuses_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "sum_followers_counts|sum_friends_counts"
          GraphPoint.save_all(records.collect{|record| {:label => record.sum_followers_count, :value => record.sum_friends_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "sum_followers_counts|sum_statuses_counts"
          GraphPoint.save_all(records.collect{|record| {:label => record.sum_followers_count, :value => record.sum_statuses_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "sum_friends_counts|sum_statuses_counts"
          GraphPoint.save_all(records.collect{|record| {:label => record.sum_friends_count, :value => record.sum_statuses_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        end
      end
      offset += limit
      records = DataMapper.repository.adapter.select(location_grouped_user_query.call(limit, offset))
    end
  end
  
  def self.finalize_analysis(curation)
    response = {}
    response[:recipient] = curation.researcher.email
    response[:subject] = "#{curation.researcher.user_name}, the raw Graph data for the basic histograms in the \"#{curation.name}\" data set is complete."
    response[:message_content] = "Your CSV files are ready for download. You can grab them by visiting the collection's page: <a href=\"http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}\">http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}</a>."
    return response
  end
end

