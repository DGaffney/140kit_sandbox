class EdgeGenerator < AnalysisMetadata
  DEFAULT_CHUNK_SIZE = 1000

  def self.run(curation_id)
    curation = Curation.first({:id => curation_id})
    conditional = Analysis.curation_conditional(curation)
    options = {:dynamic => true, :formats => ["gexf", "graphml"], :node_attributes => [:statuses_count, :followers_count, :friends_count], :edge_attributes => [:style]}
    BasicHistogram.generate_graphs([{:analysis_metadata_id => self.analysis_metadata(curation)&&self.analysis_metadata(curation).id, :style => "network_graph", :title => "edges"}], curation) do |fs, graph, conditional|
      self.generate_edges(fs, graph, conditional)
    end
  end
  
  def self.generate_edges(fs, graph, conditional)
    limit = DEFAULT_CHUNK_SIZE||1000
    offset = 0
    records = Tweet.all(conditional.merge({:fields => [:screen_name, :twitter_id, :in_reply_to_status_id, :created_at, :in_reply_to_screen_name], :in_reply_to_user_id.not => nil, :limit => limit, :offset => offset}))
    edges = []
    while !records.empty?
      records.each do |record|
        edge = {:start_node => record.in_reply_to_screen_name, :end_node => record.screen_name, :edge_id => record.twitter_id, :time => record.created_at, :curation_id => graph.curation_id, :graph_id => graph.id, :style => self.derive_style_from_tweet(record)}
        edges << edge
      end
      Edge.save_all(edges)
      edges = []
      offset+=limit
      records = Tweet.all(conditional.merge({:fields => [:screen_name, :twitter_id, :in_reply_to_status_id, :created_at, :in_reply_to_screen_name], :in_reply_to_user_id.not => nil, :limit => limit, :offset => offset}))      
    end
    offset = 0
    records = Friendship.all(conditional.merge({:limit => limit, :offset => offset}))
    edges = []
    while !records.empty?
      records.each do |record|
        edge = {:start_node => record.followed_user_name, :end_node => record.follower_user_name, :edge_id => record.followed_user_id, :time => record.created_at, :curation_id => graph.curation_id, :graph_id => graph.id, :style => "friendship"}
        edges << edge
      end
      Edge.save_all(edges)
      edges = []
      offset+=limit
      records = Friendship.all(conditional.merge({:limit => limit, :offset => offset}))      
    end
  end
  
  def self.derive_style_from_tweet(record)
    if record.in_reply_to_status_id
      return "retweet"
    else
      return "mention"
    end
  end
end
