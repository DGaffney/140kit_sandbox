class NetworkGrapher < AnalysisMetadata
  DEFAULT_CHUNK_SIZE = 1000

  def self.run(curation_id, graph_type)
    curation = Curation.first({:id => curation_id})
    return nil if !self.requires(self.analysis_metadata(curation), [{:function => "edge_generator", :with_options => [curation_id]}], curation)
    edge_generator_analysis_metadata = AnalysisMetadata.all(:finished => true, :curation_id => curation_id, "analytical_offering.function" => "edge_generator").select{|analysis_metadata| analysis_metadata.run_vars == [curation_id]}.first
    FilePathing.tmp_folder(curation, self.underscore)
    conditional = Analysis.curation_conditional(curation)
    #may turn into a huge PITA if we actually implement per-node and per-edge attributes as we could end up making many calls to db to pull out additional attributes
    options = {:dynamic => true, :formats => ["gexf", "graphml"], :node_attributes => [:statuses_count, :followers_count, :friends_count], :edge_attributes => [:style]}
    fs = {:analysis_metadata_id => self.analysis_metadata(curation)&&self.analysis_metadata(curation).id, :style => "network_graph", :title => graph_type}.merge(options).merge({:edge_conditional => self.edge_conditional(graph_type)})
    graph = Graph.first(:analysis_metadata_id => edge_generator_analysis_metadata.id, :curation_id => curation_id, :title => "edges")
    self.generate_graph_files(fs, graph)
    self.push_tmp_folder(curation.stored_folder_name)
    self.finalize(curation)
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
        edges = Edge.all(conditional.merge({:style => fs[:edge_conditional]}))
        Graphml::Writer::generate_temp_data(fs, edges)
        Gexf::Writer::generate_temp_data(fs, edges)
      end
      offset+=limit
      start_nodes = graph.edges.aggregate(:start_node, :all.count, {:limit => limit, :offset => offset, :order => :start_node})
      start_node_sets = self.calculate_start_node_sets_by_limit(start_nodes, limit)
    end
    Graphml::Writer::finalize_temp_data(fs)
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
  
  def self.edge_conditional(graph_type)
    case graph_type
    when "conversational_tweets"
      return ['retweet', 'mention']
    when "friendships"
      return 'friendship'
    when "multivariate"
      return ['retweet', 'mention', 'friendship']
    else return ['retweet', 'mention']
    end
  end
end
