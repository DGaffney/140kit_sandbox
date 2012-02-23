# entity_based_retweet_graph = AnalyticalOffering.create(:title => "Entity based retweet graph", :function => "entity_based_retweet_graph", :language => "ruby", :created_by => "140kit Team", :created_by_link => "http://140kit.com", :access_level => "user", :description => "OBL RETWEET GRAPH")
# entity_based_retweet_graph_var_0 = AnalyticalOfferingVariableDescriptor.create(:name => "curation_id", :position => 0, :kind => "integer", :analytical_offering_id=> entity_based_retweet_graph.id, :description => "Curation ID for set to be analyzed")
# entity_based_retweet_graph_var_1 = AnalyticalOfferingVariableDescriptor.create(:name => "mentioned_user", :position => 0, :kind => "string", :analytical_offering_id=> entity_based_retweet_graph.id, :description => "Mentioned User to work with")

class EntityBasedRetweetGraphWithMentionedUser < AnalysisMetadata
  DEFAULT_CHUNK_SIZE = 10000

  def self.run(curation_id, mentioned_user)
    curation = Curation.first({:id => curation_id})
    FilePathing.tmp_folder(curation, self.underscore)
    conditional = Analysis.curation_conditional(curation)
    #may turn into a huge PITA if we actually implement per-node and per-edge attributes as we could end up making many calls to db to pull out additional attributes
    options = {:dynamic => true, :formats => ["gexf", "graphml"], :node_attributes => [], :edge_attributes => [:style]}
    BasicHistogram.generate_graphs([{:analysis_metadata_id => self.analysis_metadata(curation)&&self.analysis_metadata(curation).id, :style => "network_graph", :title => "conversational_tweets_entity_based_with_mentioned_user"}.merge(options)], curation) do |fs, graph, conditional|
      self.generate_edges(fs, graph, conditional, mentioned_user)
      self.generate_graph_files(fs, graph)
    end
    self.push_tmp_folder(curation.stored_folder_name)
    self.finalize(curation)
  end
  
  def self.generate_edges(fs, graph, conditional, mentioned_user)
    limit = DEFAULT_CHUNK_SIZE||10000
    offset = 0
    query = lambda{ |mentioned_user,conditional,limit,offset| "select tweets.in_reply_to_status_id,tweets.created_at,tweets.twitter_id,tweets.screen_name,entities.value from tweets,entities where tweets.text like '%#{mentioned_user}%' and entities.name = 'user_mention_screen_name' and #{Analysis.conditions_to_mysql_query(conditional).gsub("dataset_id", "tweets.dataset_id")} and  entities.twitter_id = tweets.twitter_id limit #{limit} offset #{offset}"}
    records = DataMapper.repository.adapter.select(query.call(mentioned_user,conditional,limit,offset))
    previous_twitter_id = records.first.twitter_id
    edges = []
    while !records.empty?
      records.each do |record|
        if previous_twitter_id != record.twitter_id
          #this enforces only one storage per tweet
          edge = {:start_node => record.value, :end_node => record.screen_name, :edge_id => record.twitter_id, :time => record.created_at, :curation_id => graph.curation_id, :graph_id => graph.id, :style => self.derive_style_from_tweet(record)+"_entity"}
          previous_twitter_id = record.twitter_id
          edges << edge
        end
      end
      Edge.save_all(edges)
      edges = []
      offset+=limit
      records = DataMapper.repository.adapter.select(query.call(mentioned_user,conditional,limit,offset))
    end
    Edge.save_all(edges)
  end
  
  def self.generate_graph_files(fs, graph, conditional={:graph_id => graph.id})
    # Graphml::Writer::initialize_temp_data(fs, graph)
    Gexf::Writer::initialize_temp_data(fs, graph)
    limit = DEFAULT_CHUNK_SIZE||1000
    offset = 0
    fs[:total_range] = graph.reload.edges.last(:order => :time).time-graph.edges.first(:order => :time).time
    start_nodes = graph.edges.aggregate(:start_node, :all.count, {:limit => limit, :offset => offset, :order => :start_node})
    start_node_sets = self.calculate_start_node_sets_by_limit(start_nodes, limit)
    while !start_nodes.empty?
      start_node_sets.each do |start_node_set|
        conditional = conditional.merge({:start_node => start_node_set})
        edges = Edge.all(conditional)
        # Graphml::Writer::generate_temp_data(fs, edges)
        Gexf::Writer::generate_temp_data(fs, edges)
      end
      offset+=limit
      start_nodes = graph.edges.aggregate(:start_node, :all.count, {:limit => limit, :offset => offset, :order => :start_node})
      start_node_sets = self.calculate_start_node_sets_by_limit(start_nodes, limit)
    end
    # Graphml::Writer::finalize_temp_data(fs)
    Gexf::Writer::finalize_temp_data(fs)
    graph.written = true
    graph.save!
  end
  
  def self.calculate_start_node_sets_by_limit(start_nodes, start_node_limit)
    start_node_sets = []
    current_count = 0
    start_node_set = []
    start_nodes.each do |start_node, count|
      if current_count <= start_node_limit
        current_count += count
        start_node_set << start_node
      else
        start_node_sets << start_node_set
        current_count = count
        start_node_set = []
        start_node_set << start_node
      end
    end
    start_node_sets << start_node_set
    return start_node_sets
  end
  
  def self.derive_style_from_tweet(record)
    if record.in_reply_to_status_id
      return "retweet"
    else
      return "mention"
    end
  end
end
