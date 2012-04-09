class AudienceReport
  
  def self.run(analysis_metadata_id)
    @analysis_metadata = AnalysisMetadata.first(:id => analysis_metadata_id)
    curation = @analysis_metadata.curation
    conditional = Analysis.curation_conditional(curation)
    audience_overview_graph = Graph.first_or_create(:title => "audience_overview", :style => "table", :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id)
    impressions = User.sum(:followers_count, conditional)
    top_20_impressioning_users = User.all(conditional.merge({:order => :followers_count, :limit => 20, :fields => [:screen_name, :followers_count]}))
    total_retweets = Tweet.count(conditional.merge({:in_reply_to_status_id.not => nil}))
    total_replies = Tweet.count(conditional.merge({:in_reply_to_status_id => nil, :in_reply_to_screen_name.not => nil}))
    total_regulars = Tweet.count(conditional.merge({:in_reply_to_status_id => nil, :in_reply_to_screen_name => nil}))
    impressions_over_time = Graph.first_or_create(:title => "impressions_over_time", :style => "table", :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id)
    first = Tweet.first(conditional.merge({:order => :created_at})).created_at
    last = Tweet.last(conditional.merge({:order => :created_at})).created_at
    length = (first-last).abs
    date_format = Pretty.time_interval(length, DataMapper.repository.adapter.options["adapter"])
    limit = 10000
    offset = 0
    results = DataMapper.repository.adapter.select("select date_format(tweets.created_at, '%Y-%m-%d %H:%i:00') as time,sum(users.followers_count) as impressions from tweets inner join users on users.twitter_id = tweets.user_id where tweets.dataset_id = 16 group by date_format(tweets.created_at, '%Y-%m-%d %H:%i:00') limit #{limit} offset #{offset}")
    while !results.empty?
      graph_points = []
      results.each do |result|
        graph_points << {:label => result.time, :value => result.impressions}
      end
      GraphPoint.save_all(graph_points.collect{|w| w.merge({:curation_id => curation.id, :analysis_metadata_id => @analysis_metadata.id, :graph_id => impressions_over_time.id})})
      graph_points = []
      offset+=limit
      results = DataMapper.repository.adapter.select("select date_format(tweets.created_at, '%Y-%m-%d %H:%i:00') as time,sum(users.followers_count) as impressions from tweets inner join users on users.twitter_id = tweets.user_id where tweets.dataset_id = 16 group by date_format(tweets.created_at, '%Y-%m-%d %H:%i:00') limit #{limit} offset #{offset}")      
    end
  end
end