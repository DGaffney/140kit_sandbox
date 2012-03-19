class Pretty
  
  def self.language_map
    {"en" => "English", "ja" => "Japanese", "it" => "Italian", "de" => "German", "fr" => "French", "kr" => "Korean", "es" => "Spanish", "id" => "Indonesian", "fil" => "Filipino", "nl" => "Dutch", "pt" => "Portuguese"}
  end

  def self.pretty_up_labels(graph, graph_points)
    case graph.title
    when "tweets_location"
      graph_points = Pretty.location(graph_points)
    when "tweets_language"
      graph_points.collect{|graph_point| graph_point[:label] = Pretty.language(graph_point[:label])}
    when "tweets_source"
      graph_points.collect{|graph_point| graph_point[:label] = Pretty.source(graph_point[:label])}
    when "users_lang"
      graph_points.collect{|graph_point| graph_point[:label] = Pretty.language(graph_point[:label])}
    end
    return graph_points
  end
  
  def self.location(graph_points)
    graph_points.select{|graph_point| graph_point[:label] = "Not Reported" if graph_point[:label].nil?}
    iphone_graph_points = graph_points.select{|graph_point| graph_point[:label].include?("UT:") || graph_point[:label].include?("iPhone:")}
    iphone_graph_point = iphone_graph_points.empty?  ? nil : {:label => "iPhone Location", :curation_id => graph_points.first[:curation_id], :graph_id => graph_points.first[:graph_id], :value => iphone_graph_points.length}
    pre_graph_points = graph_points.select{|graph_point| graph_point[:label].include?("Pre:")}
    pre_graph_point = pre_graph_points.empty?  ? nil : {:label => "Palm Pre Location", :curation_id => graph_points.first[:curation_id], :graph_id => graph_points.first[:graph_id], :value => pre_graph_points.length}
    new_graph_points = ((graph_points-[iphone_graph_points,pre_graph_points].flatten)+[iphone_graph_point,pre_graph_point].flatten).compact
    return new_graph_points
  end

  def self.language(language)
    return self.language_map[language] || language
  end
    
  def self.source(source)
    if source && source.include?("</a>")
      source = source.scan(/>(.*)</)[0][0]
    end
    return source.gsub("\"", "\\\"")
  end
end
