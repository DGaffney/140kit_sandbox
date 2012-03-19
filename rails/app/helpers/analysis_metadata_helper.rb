module AnalysisMetadataHelper
  def analysis_metadata_partial_path(analysis_metadata)
    "/analysis_metadata/analytics/#{analysis_metadata.function}/#{analysis_metadata.function}"
  end
  
  def analysis_metadata_partial_graph_path(graph)
    "/analytics/#{graph.analysis_metadata.id}/#{graph.id}/graph"
  end
end
