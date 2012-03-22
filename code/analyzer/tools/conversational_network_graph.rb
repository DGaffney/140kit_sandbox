class ConversationalNetworkGraph < AnalysisMetadata
  def self.verify_variable(metadata, analytical_offering_variable, answer)
    case analytical_offering_variable.name
    when "network_type"
      valid_responses = ["retweet", "mention", "combined"]
      response = {}
      response[:reason] = "You may only choose one of these options, and only these options (can't be left blank). You entered: #{answer}. You can choose from ['year','month','date','hour']."
      response[:variable] = answer
      return response if !valid_responses.include?(answer)
    end
    return {:variable => answer}
  end
  
  def self.run(analysis_metadata_id, network_type)
    @analysis_metadata = AnalysisMetadata.first(:id => analysis_metadata_id)
    return false if !self.requires(@analysis_metadata.curation, [{:function => "interaction_list"}], curation)
    self.draw_graph(network_type)
    return true
  end
  
  def self.draw_graph(network_type)
    curation = @analysis_metadata.curation
    debugger
    conditional = Analysis.curation_conditional(curation)
    graph_ids = []
    edge_conditional = []
    if network_type == "combined"
      graph_ids = Graph.all(:title => ["retweet_network", "mention_network"], :style => "network", :curation => curation.id).collect(&:id)
      edge_conditional << ["mention", "retweet"]
    else
      edge_conditional << network_type
      graph_ids << Graph.first(:title => "#{network_type}_network", :style => "network", :curation_id => curation.id).id
    end
    offset = 0
    limit = 20000
    options = {
      :dynamic => true, 
      :formats => ["gexf", "graphml"], 
      :node_attributes => [:statuses_count, :followers_count, :friends_count], 
      :edge_attributes => [:style],
      :analysis_metadata_id => @analysis_metadata.id, 
      :style => network_type+"_graph", 
      :title => "curation_#{curation.id}_#{curation.name}",
      :edge_conditional => edge_conditional,
      :total_range => Edge.last(:order => :time, :graph_id => graph_ids).time-Edge.first(:order => :time, :graph_id => graph_ids).time
    }
    Graphml::Writer::initialize_temp_data(options, graph)
    Gexf::Writer::initialize_temp_data(options, graph)
    edges = Edge.all(:graph_id => graph_ids, :limit => limit, :offset => offset)
    while !edges.empty?
      Graphml::Writer::generate_temp_data(options, edges)
      Gexf::Writer::generate_temp_data(options, edges)
      offset+=limit
      edges = Edge.all(:graph_id => graph_ids, :limit => limit, :offset => offset)
    end
    Graphml::Writer::finalize_temp_data(options)
    Gexf::Writer::finalize_temp_data(options)
    graph.written = true
    graph.save!
  end
end

