class GraphPoint
  include DataMapper::Resource
  property :id, Serial
  property :label, String, :index => [:label_value_graph_id, :label_value, :label_curation_id, :label_graph_id_curation_id], :length => 255
  property :value, String, :index => [:label_value_graph_id, :label_value], :length => 255
  property :curation_id, Integer, :index => [:label_curation_id, :label_graph_id_curation_id, :curation_id, :graph_id_curation_id]
  property :graph_id, Integer, :index => [:label_value_graph_id, :label_graph_id_curation_id, :graph_id, :graph_id_curation_id]
  belongs_to :graph, :child_key => :graph_id
  belongs_to :analysis_metadata, :index => [:graph_id_analysis_metadata_id, :analysis_metadata_id]
  belongs_to :curation, :child_key => :curation_id
end