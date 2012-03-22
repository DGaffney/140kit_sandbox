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
    debugger
    gg = ""
    if network_type == "combined"
      self.draw_combined_graph
    else
      self.draw_individual_graph(network_type)
    end
  end
  
  def self.draw_individual_graph(network_type)
    curation = @analysis_metadata.curation
    return false if !self.requires(self.analysis_metadata(curation), [{:function => "interaction_list"}], curation)
    conditional = Analysis.curation_conditional(curation)
    graph = Graph.first(:title => "#{network_type}_network", :style => "network", :curation_id => curation.id)
    offset = 0
    limit = 20000
    
    header_file = File.opwn
  end
  def self.detect_language_name(data)
    value = $language_map.invert[CLD.detect_language(data)]
    value = "unknown" if value == "TG_UNKNOWN_LANGUAGE"
    return value.split("_").collect(&:capitalize).join(" ")
  end
end

