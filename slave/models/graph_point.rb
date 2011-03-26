class GraphPoint
  include DataMapper::Resource
  property :id, Serial
  property :label, String, :unique_index => [:unique_graph_point], :index => [:label_value_graph_id, :label_value, :label_curation_id, :label_graph_id_curation_id]
  property :value, Float, :unique_index => [:unique_graph_point], :index => [:label_value_graph_id, :label_value]
  belongs_to :graph, :unique_index => [:unique_graph_point], :index => [:label_value_graph_id, :label_graph_id_curation_id, :graph_id, :graph_id_curation_id]
  belongs_to :curation, :unique_index => [:unique_graph_point], :index => [:label_curation_id, :label_graph_id_curation_id, :curation_id, :graph_id_curation_id]
  
  def self.sanitize_points(graph, graph_points)
    return Pretty.pretty_up_labels(graph.style, graph.title, graph_points)
  end
end