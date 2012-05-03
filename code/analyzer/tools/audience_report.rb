class AudienceReport

  def self.run(analysis_metadata_id)
    @analysis_metadata = AnalysisMetadata.first(:id => analysis_metadata_id)
    curation = @analysis_metadata.curation
    conditional = Analysis.curation_conditional(curation)
    audience_overview_graph = Graph.first_or_create(:title => "tweet_type_breakdown", :style => "table", :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id)
    top_impressioning_users = Graph.first_or_create(:title => "top_impression_generating_users", :style => "table", :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id)
    impressions = User.sum(:followers_count, conditional)
    top_20_impressioning_users = User.all(conditional.merge({:order => :followers_count.desc, :limit => 20, :fields => [:screen_name, :followers_count]}))
    total_retweets = Tweet.count(conditional.merge({:in_reply_to_status_id.not => 0}))
    total_replies = Tweet.count(conditional.merge({:in_reply_to_status_id => 0, :in_reply_to_user_id.not => 0}))
    total_regulars = Tweet.count(conditional.merge({:in_reply_to_status_id => 0, :in_reply_to_user_id => 0}))
    graph_points = []
    graph_points << {:label => "total_retweets", :value => total_retweets, :curation_id => curation.id, :analysis_metadata_id => @analysis_metadata.id, :graph_id => audience_overview_graph.id}
    graph_points << {:label => "total_replies", :value => total_replies, :curation_id => curation.id, :analysis_metadata_id => @analysis_metadata.id, :graph_id => audience_overview_graph.id}
    graph_points << {:label => "total_regulars", :value => total_regulars, :curation_id => curation.id, :analysis_metadata_id => @analysis_metadata.id, :graph_id => audience_overview_graph.id}
    top_20_impressioning_users.each do |user|
      graph_points << {:label => user.screen_name, :value => user.followers_count, :curation_id => curation.id, :analysis_metadata_id => @analysis_metadata.id, :graph_id => top_impressioning_users.id}
    end
    impressions_over_time = Graph.first_or_create(:title => "impressions_over_time", :style => "table", :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id)
    graph_points << {:label => "total_impressions", :value => impressions, :curation_id => curation.id, :analysis_metadata_id => @analysis_metadata.id, :graph_id => impressions_over_time.id}
    GraphPoint.save_all(graph_points)
    first = Tweet.first(conditional.merge({:order => :created_at})).created_at
    last = Tweet.last(conditional.merge({:order => :created_at})).created_at
    length = (first-last).abs
    date_format = Pretty.time_interval(length, DataMapper.repository.adapter.options["adapter"])
    limit = 10000
    offset = 0
    results = DataMapper.repository.adapter.select("select date_format(tweets.created_at, '#{date_format}') as time,sum(users.followers_count) as impressions from tweets inner join users on users.twitter_id = tweets.user_id where tweets.dataset_id in (#{[conditional[:dataset_id]].flatten.join(",")}) group by date_format(tweets.created_at, '#{date_format}') limit #{limit} offset #{offset}")
    while !results.empty?
      graph_points = []
      results.each do |result|
        graph_points << {:label => result.time, :value => result.impressions}
      end
      GraphPoint.save_all(graph_points.collect{|w| w.merge({:curation_id => curation.id, :analysis_metadata_id => @analysis_metadata.id, :graph_id => impressions_over_time.id})})
      graph_points = []
      offset+=limit
      results = DataMapper.repository.adapter.select("select date_format(tweets.created_at, '#{date_format}') as time,sum(users.followers_count) as impressions from tweets inner join users on users.twitter_id = tweets.user_id where tweets.dataset_id in (#{[conditional[:dataset_id]].flatten.join(",")}) group by date_format(tweets.created_at, '#{date_format}') limit #{limit} offset #{offset}")
    end
    GraphPoint.save_all(graph_points.collect{|w| w.merge({:curation_id => curation.id, :analysis_metadata_id => @analysis_metadata.id, :graph_id => impressions_over_time.id})})
    return true
  end

end