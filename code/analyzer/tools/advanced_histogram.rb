class AdvancedHistogram < AnalysisMetadata

  DEFAULT_CHUNK_SIZE = 10000
  
  #Results: Frequency Charts of basic data on Tweets and Users per data set
  def self.run(curation_id)
    curation = Curation.first(:id => curation_id)
    FilePathing.tmp_folder(curation, self.underscore)
    path=ENV['TMP_PATH']
    self.generate_sequential_tweet_graphs(curation, path)
    self.generate_sequential_user_graphs(curation, path)
    self.generate_user_avg_sum_graphs(curation, path)
    self.push_tmp_folder(curation.stored_folder_name)
    self.finalize(curation)
  end

  def self.generate_sequential_tweet_graphs(curation, path=ENV['TMP_PATH'], additional_query={}, analytic=self, title_suffix="")
    title_suffix = title_suffix.empty? ? "" : "_#{title_suffix}"
    sequential_tweet_graphs = []
    #can be run sequentially
    sequential_tweet_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "hashtag_count_retweet_count#{title_suffix}")
    sequential_tweet_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "link_count_retweet_count#{title_suffix}")
    sequential_tweet_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "mention_count_retweet_count#{title_suffix}")
    sequential_tweet_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "entity_count_retweet_count#{title_suffix}")
    sequential_tweet_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "source_retweet_counts#{title_suffix}")
    sequential_tweet_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "source_link_count#{title_suffix}")
    sequential_tweet_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "source_mention_count#{title_suffix}")
    sequential_tweet_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "source_entity_count#{title_suffix}")
    sequential_tweet_graph_csvs = sequential_tweet_graphs.collect{|graph| FasterCSV.open(path+"/"+graph.title+".csv", "w")}
    sequential_tweet_graph_initialized = sequential_tweet_graphs.collect{|graph| true}
    conditional = Analysis.curation_conditional(curation).merge(additional_query)
    self.initialize_graphs(sequential_tweet_graphs, sequential_tweet_graph_csvs)
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
        csv = sequential_tweet_graph_csvs[sequential_tweet_graphs.index(sequential_tweet_graph)]
        case sequential_tweet_graph.title
        when "hashtag_count_retweet_count"
          records.collect{|record| csv << [record.hashtag_count, record.retweet_count]}
          GraphPoint.save_all(records.collect{|record| {:label => record.hashtag_count, :value => record.retweet_count, :graph_id => sequential_tweet_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "link_count_retweet_count"
          records.collect{|record| csv << [record.links_count, record.retweet_count]}
          GraphPoint.save_all(records.collect{|record| {:label => record.links_count, :value => record.retweet_count, :graph_id => sequential_tweet_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "mention_count_retweet_count"
          records.collect{|record| csv << [record.mentions_count, record.retweet_count]}
          GraphPoint.save_all(records.collect{|record| {:label => record.mentions_count, :value => record.retweet_count, :graph_id => sequential_tweet_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "entity_count_retweet_count"
          records.collect{|record| csv << [record.all_entities_count, record.retweet_count]}          
          GraphPoint.save_all(records.collect{|record| {:label => record.all_entities_count, :value => record.retweet_count, :graph_id => sequential_tweet_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "source_retweet_counts"
          records.collect{|record| csv << [record.source, record.retweet_count]}
          GraphPoint.save_all(records.collect{|record| {:label => record.source, :value => record.retweet_count, :graph_id => sequential_tweet_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "source_link_count"
          records.collect{|record| csv << [record.source, record.links_count]}
          GraphPoint.save_all(records.collect{|record| {:label => record.source, :value => record.links_count, :graph_id => sequential_tweet_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "source_mention_count"
          records.collect{|record| csv << [record.source, record.mentions_count]}
          GraphPoint.save_all(records.collect{|record| {:label => record.source, :value => record.mentions_count, :graph_id => sequential_tweet_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "source_entity_count"
          records.collect{|record| csv << [record.source, record.all_entities_count]}
          GraphPoint.save_all(records.collect{|record| {:label => record.source, :value => record.all_entities_count, :graph_id => sequential_tweet_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        end
      end
      offset+=limit
      records = DataMapper.repository.adapter.select(full_entity_matched_query.call(conditional, limit, offset))
    end
    sequential_tweet_graph_csvs.collect{|csv| csv.close}
  end

  def self.generate_tweet_avg_sum_graphs(curation, path=ENV['TMP_PATH'], additional_query={}, analytic=self, title_suffix="")
    limit = DEFAULT_CHUNK_SIZE
    conditional = Analysis.curation_conditional(curation)
    FilePathing.tmp_folder(curation, analytic.underscore)
    path=ENV['TMP_PATH']
    #need to be run on their own
    tweets_per_minute                    = Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "tweets_per_minute#{title_suffix}")
    retweets_per_minute                  = Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "retweets_per_minute#{title_suffix}")
    tweets_per_minute_csv = FasterCSV.open(path+"/"+tweets_per_minute.title+".csv", "w")
    retweets_per_minute_csv = FasterCSV.open(path+"/"+retweets_per_minute.title+".csv", "w")
    tweets_per_minute_csv << ["created_at", "tweet_count"]
    retweets_per_minute_csv << ["created_at", "retweet_count"]
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
      records.collect{|record| tweets_per_minute_csv << [record.created_at, record.tweet_count]}
      records.collect{|record| retweets_per_minute_csv << [record.created_at, record.retweet_count]}
      GraphPoint.save_all(records.collect{|record| {:label => record.created_at, :value => record.tweet_count, :graph_id => tweets_per_minute.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
      GraphPoint.save_all(records.collect{|record| {:label => record.created_at, :value => record.retweet_count, :graph_id => retweets_per_minute.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
      offset += limit
      records = DataMapper.repository.adapter.select(time_based_tweet_query.call(limit, offset))
    end
    tweets_per_minute_csv.close
    retweets_per_minute_csv.close
  end
  
  def self.generate_sequential_user_graphs(curation, path=ENV['TMP_PATH'], additional_query={}, analytic=self, title_suffix="")
    limit = DEFAULT_CHUNK_SIZE
    conditional = Analysis.curation_conditional(curation).merge(additional_query)
    FilePathing.tmp_folder(curation, analytic.underscore)    
    #can be run sequentially
    sequential_user_graphs = []
    sequential_user_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "followers_count_friends_count#{title_suffix}")
    sequential_user_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "followers_count_statuses_count#{title_suffix}")
    sequential_user_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "friends_count_statuses_count#{title_suffix}")
    sequential_user_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "followers_per_day#{title_suffix}")
    sequential_user_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "friends_per_day#{title_suffix}")
    sequential_user_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "statuses_per_day#{title_suffix}")
    sequential_user_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "followers_per_day_avg_friends_per_day_avg#{title_suffix}")
    sequential_user_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "followers_per_day_avg_statuses_per_day_avg#{title_suffix}")
    sequential_user_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "friends_per_day_avg_statuses_per_day_avg#{title_suffix}")
    sequential_user_graph_csvs = sequential_user_graphs.collect{|graph| FasterCSV.open(path+"/"+graph.title+".csv", "w")}
    self.initialize_graphs(sequential_user_graphs, sequential_user_graph_csvs)

    offset = 0
    records = User.all(conditional.merge({:limit => limit, :offset => offset}))
    while !records.empty?
      sequential_user_graphs.each do |sequential_user_graph|
        csv = sequential_user_graph_csvs[sequential_user_graphs.index(sequential_user_graph)]
        case sequential_user_graph.title
        when "followers_count_friends_count"
          records.collect{|record| csv << [record.followers_count, record.friends_count]}
          GraphPoint.save_all(records.collect{|record| {:label => record.followers_count, :value => record.friends_count, :graph_id => sequential_user_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "followers_count_statuses_count"
          records.collect{|record| csv << [record.followers_count, record.statuses_count]}
          GraphPoint.save_all(records.collect{|record| {:label => record.followers_count, :value => record.statuses_count, :graph_id => sequential_user_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "friends_count_statuses_count"
          records.collect{|record| csv << [record.friends_count, record.statuses_count]}
          GraphPoint.save_all(records.collect{|record| {:label => record.friends_count, :value => record.statuses_count, :graph_id => sequential_user_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "followers_per_day"
          records.collect{|record| csv << [record.twitter_id, record.followers_count.to_f/((Time.now-record.created_at).to_f/86400.0)]}
          GraphPoint.save_all(records.collect{|record| {:label => record.twitter_id, :value => record.followers_count.to_f/((Time.now-record.created_at).to_f/86400.0), :graph_id => sequential_user_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "friends_per_day"
          records.collect{|record| csv << [record.twitter_id, record.friends_count.to_f/((Time.now-record.created_at).to_f/86400.0)]}
          GraphPoint.save_all(records.collect{|record| {:label => record.twitter_id, :value => record.friends_count.to_f/((Time.now-record.created_at).to_f/86400.0), :graph_id => sequential_user_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "statuses_per_day"
          records.collect{|record| csv << [record.twitter_id, record.statuses_count.to_f/((Time.now-record.created_at).to_f/86400.0)]}
          GraphPoint.save_all(records.collect{|record| {:label => record.twitter_id, :value => record.statuses_count.to_f/((Time.now-record.created_at).to_f/86400.0), :graph_id => sequential_user_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "followers_per_day_avg_friends_per_day_avg"
          records.collect{|record| csv << [record.followers_count.to_f/((Time.now-record.created_at).to_f/86400.0), record.friends_count.to_f/((Time.now-record.created_at).to_f/86400.0)]}
          GraphPoint.save_all(records.collect{|record| {:label => record.followers_count.to_f/((Time.now-record.created_at).to_f/86400.0), :value => record.friends_count.to_f/((Time.now-record.created_at).to_f/86400.0), :graph_id => sequential_user_graph.id, :analysis_metadata_id =>  analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "followers_per_day_avg_statuses_per_day_avg"
          records.collect{|record| csv << [record.followers_count.to_f/((Time.now-record.created_at).to_f/86400.0), record.statuses_count.to_f/((Time.now-record.created_at).to_f/86400.0)]}
          GraphPoint.save_all(records.collect{|record| {:label => record.followers_count.to_f/((Time.now-record.created_at)/86400.0), :value => record.statuses_count.to_f/((Time.now-record.created_at).to_f/86400.0), :graph_id => sequential_user_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "friends_per_day_avg_statuses_per_day_avg"
          records.collect{|record| csv << [record.friends_count.to_f/((Time.now-record.created_at).to_f/86400.0), record.statuses_count.to_f/((Time.now-record.created_at).to_f/86400.0)]}
          GraphPoint.save_all(records.collect{|record| {:label => record.friends_count.to_f/((Time.now-record.created_at).to_f/86400.0), :value => record.statuses_count.to_f/((Time.now-record.created_at).to_f/86400.0), :graph_id => sequential_user_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        end
      end
      offset += limit
      records = User.all(conditional.merge({:limit => limit, :offset => offset}))
    end
    sequential_user_graph_csvs.collect{|csv| csv.close}
  end
  
  def self.generate_user_avg_sum_graphs(curation, path=ENV['TMP_PATH'], additional_query={}, analytic=self, title_suffix="")
    limit = DEFAULT_CHUNK_SIZE
    
    conditional = Analysis.curation_conditional(curation).merge(additional_query)
    FilePathing.tmp_folder(curation, analytic.underscore)
    path=ENV['TMP_PATH']
    #need to be run on their own
    user_avg_sum_graphs = []
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "location_avg_followers_counts#{title_suffix}")
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "location_avg_friends_counts#{title_suffix}")
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "location_avg_statuses_counts#{title_suffix}")
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "location_sum_followers_counts#{title_suffix}")
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "location_sum_friends_counts#{title_suffix}")
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "location_sum_statuses_counts#{title_suffix}")
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "avg_followers_counts_avg_friends_counts#{title_suffix}")
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "avg_followers_counts_avg_statuses_counts#{title_suffix}")
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "avg_friends_counts_avg_statuses_counts#{title_suffix}")
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "sum_followers_counts_sum_friends_counts#{title_suffix}")
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "sum_followers_counts_sum_statuses_counts#{title_suffix}")
    user_avg_sum_graphs << Graph.first_or_create(:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :style => "histogram", :title => "sum_friends_counts_sum_statuses_counts#{title_suffix}")
    user_avg_sum_graph_csvs = user_avg_sum_graphs.collect{|graph| FasterCSV.open(path+"/"+graph.title+".csv", "w")}
    self.initialize_graphs(user_avg_sum_graphs, user_avg_sum_graph_csvs)
    location_grouped_user_query = lambda{|limit, offset| "select avg(followers_count) as avg_followers_count,avg(friends_count) as avg_friends_count,avg(statuses_count) as avg_statuses_count,sum(followers_count) as sum_followers_count,sum(friends_count) as sum_friends_count,sum(statuses_count) as sum_statuses_count,location from users #{Analysis.conditions_to_mysql_query(conditional).gsub("dataset_id","tweets.dataset_id")} group by location limit #{limit} offset #{offset}"}
    offset = 0
    records = DataMapper.repository.adapter.select(location_grouped_user_query.call(limit, offset))
    while !records.empty?
      user_avg_sum_graphs.each do |user_avg_sum_graph|
        csv = user_avg_sum_graph_csvs[user_avg_sum_graphs.index(user_avg_sum_graph)]
        case user_avg_sum_graph.title
        when "location_avg_followers_counts"
          records.collect{|record| csv << [record.location, record.avg_followers_count]}
          GraphPoint.save_all(records.collect{|record| {:label => record.location, :value => record.avg_followers_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "location_avg_friends_counts"
          records.collect{|record| csv << [record.location, record.avg_friends_count]}
          GraphPoint.save_all(records.collect{|record| {:label => record.location, :value => record.avg_friends_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "location_avg_statuses_counts"
          records.collect{|record| csv << [record.location, record.avg_statuses_count]}
          GraphPoint.save_all(records.collect{|record| {:label => record.location, :value => record.avg_statuses_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "location_sum_followers_counts"
          records.collect{|record| csv << [record.location, record.sum_followers_count]}
          GraphPoint.save_all(records.collect{|record| {:label => record.location, :value => record.sum_followers_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "location_sum_friends_counts"
          records.collect{|record| csv << [record.location, record.sum_friends_count]}
          GraphPoint.save_all(records.collect{|record| {:label => record.location, :value => record.sum_followers_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "location_sum_statuses_counts"
          records.collect{|record| csv << [record.location, record.sum_statuses_count]}
          GraphPoint.save_all(records.collect{|record| {:label => record.location, :value => record.sum_statuses_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "avg_followers_counts_avg_friends_counts"
          records.collect{|record| csv << [record.avg_followers_count, record.avg_friends_count]}
          GraphPoint.save_all(records.collect{|record| {:label => record.avg_followers_count, :value => record.avg_friends_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "avg_followers_counts_avg_statuses_counts"
          records.collect{|record| csv << [record.avg_followers_count, record.avg_statuses_count]}
          GraphPoint.save_all(records.collect{|record| {:label => record.avg_followers_count, :value => record.avg_statuses_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "avg_friends_counts_avg_statuses_counts"
          records.collect{|record| csv << [record.avg_friends_count, record.avg_statuses_count]}
          GraphPoint.save_all(records.collect{|record| {:label => record.avg_friends_count, :value => record.avg_statuses_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "sum_followers_counts_sum_friends_counts"
          records.collect{|record| csv << [record.sum_followers_count, record.sum_friends_count]}
          GraphPoint.save_all(records.collect{|record| {:label => record.sum_followers_count, :value => record.sum_friends_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "sum_followers_counts_sum_statuses_counts"
          records.collect{|record| csv << [record.sum_followers_count, record.sum_statuses_count]}
          GraphPoint.save_all(records.collect{|record| {:label => record.sum_followers_count, :value => record.sum_statuses_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        when "sum_friends_counts_sum_statuses_counts"
          records.collect{|record| csv << [record.sum_friends_count, record.sum_statuses_count]}
          GraphPoint.save_all(records.collect{|record| {:label => record.sum_friends_count, :value => record.sum_statuses_count, :graph_id => user_avg_sum_graph.id, :analysis_metadata_id => analytic.analysis_metadata(curation).id, :curation_id => curation.id}})
        end
      end
      offset += limit
      records = DataMapper.repository.adapter.select(location_grouped_user_query.call(limit, offset))
    end
    user_avg_sum_graph_csvs.collect{|csv| csv.close}
  end
  
  def self.initialize_graphs(graphs, csvs)
    graphs.each do |graph|
      csv = csvs[graphs.index(graph)]
      case graph.title
      when "hashtag_count_retweet_count"
        csv << ["hashtag_count", "retweet_count"]
      when "link_count_retweet_count"
        csv << ["link_count", "retweet_count"]
      when "mention_count_retweet_count"
        csv << ["mention_count", "retweet_count"]
      when "entity_count_retweet_count"
        csv << ["entity_count", "retweet_count"]
      when "source_retweet_counts"
        csv << ["source", "retweet_count"]
      when "source_link_count"
        csv << ["source", "link_count"]
      when "source_mention_count"
        csv << ["source, ""mention_count"]
      when "source_entity_count"
        csv << ["source", "entity_count"]
      when "location_avg_followers_counts"
        csv << ["location", "avg_followers_count"]
      when "location_avg_friends_counts"
        csv << ["location", "avg_friends_count"]
      when "location_avg_statuses_counts"
        csv << ["location", "avg_statuses_count"]
      when "location_sum_followers_counts"
        csv << ["location", "sum_followers_count"]
      when "location_sum_friends_counts"
        csv << ["location", "sum_friends_count"]
      when "location_sum_statuses_counts"
        csv << ["location", "sum_statuses_count"]
      when "followers_count_friends_count"
        csv << ["followers_count", "friends_count"]
      when "followers_count_statuses_count"
        csv << ["followers_count", "statuses_count"]
      when "friends_count_statuses_count"
        csv << ["friends_count", "statuses_count"]
      when "followers_per_day"
        csv << ["twitter_id", "followers_per_day"]
      when "friends_per_day"
        csv << ["twitter_id", "friends_per_day"]
      when "statuses_per_day"
        csv << ["twitter_id", "statuses_per_day"]
      when "followers_per_day_avg_friends_per_day_avg"
        csv << ["followers_per_day", "friends_per_day"]
      when "followers_per_day_avg_statuses_per_day_avg"
        csv << ["followers_per_day", "statuses_per_day"]
      when "friends_per_day_avg_statuses_per_day_avg"
        csv << ["friends_per_day", "statuses_per_day"]        
      when "avg_followers_counts_avg_friends_counts"
        csv << ["avg_followers_counts", "avg_friends_counts"]
      when "avg_followers_counts_avg_statuses_counts"
        csv << ["avg_followers_counts", "avg_statuses_counts"]
      when "avg_friends_counts_avg_statuses_counts"
        csv << ["avg_friends_counts", "avg_statuses_counts"]
      when "sum_followers_counts_sum_friends_counts"
        csv << ["sum_followers_counts", "sum_friends_counts"]
      when "sum_followers_counts_sum_statuses_counts"
        csv << ["sum_followers_counts", "sum_statuses_counts"]
      when "sum_friends_counts_sum_statuses_counts"
        csv << ["sum_friends_counts", "sum_statuses_counts"]
      end
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

