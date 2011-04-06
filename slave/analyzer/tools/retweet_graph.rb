class RetweetGraph < AnalysisMetadata
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
    FilePathing.tmp_folder(curation, self.underscore)
    conditional = Analysis.curation_conditional(curation)
    #may turn into a huge PITA if we actually implement per-node and per-edge attributes as we could end up making many calls to db to pull out additional attributes
    options = {:dynamic => true, :formats => ["gexf", "graphml"], :node_attributes => [:statuses_count, :followers_count, :friends_count], :edge_attributes => []}
    BasicHistogram.generate_graphs([{:analysis_metadata_id => self.analysis_metadata&&self.analysis_metadata.id, :style => "network_graph", :title => "conversational_tweets"}.merge(options)], curation) do |fs, graph, curation|
      self.generate_edges(fs, graph, conditional)
      self.generate_graph_files(fs, graph)
    end
    graph = Graph.first_or_create({:curation_id => curation_id, :analysis_metadata_id => self.analysis_metadata&&self.analysis_metadata.id}.merge(graph_attrs))
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
  end
  
  def self.generate_graph_files(fs, graph, conditional={:graph_id => graph.id})
    Graphml::Writer::initialize_temp_data(fs, graph)
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
        Graphml::Writer::generate_temp_data(fs, edges)
        Gexf::Writer::generate_temp_data(fs, edges)
      end
      start_nodes = graph.edges.aggregate(:start_node, :all.count, {:limit => limit, :offset => offset, :order => :start_node})
      start_node_sets = self.calculate_start_node_sets_by_limit(start_nodes, start_node_limit)
    end
    Graphml::Writer::finalize_temp_data
    Gexf::Writer::finalize_temp_data
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
