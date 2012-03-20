module AnalysisMetadataHelper
  def analysis_metadata_partial_path(analysis_metadata)
    if File.exists?(Rails.root.join("app", "views", "analysis_metadata", "analytics", analysis_metadata.function, "_analytic_view.html.slim")) || File.exists?(Rails.root.join("app", "views", "analysis_metadata", "analytics", analysis_metadata.function, "_analytic_view.html.erb"))
      return "/analysis_metadata/analytics/#{analysis_metadata.function}/analytic_view"
    else
      return "/analysis_metadata/analytics/analytic_view"
    end
  end
  
  def analysis_metadata_partial_graph_path(graph)
    "/analytics/#{graph.analysis_metadata.id}/#{graph.id}/graph"
  end
  
  def analysis_metadata_partial_view_path(analysis_metadata)
    if File.exists?(Rails.root.join("app", "views", "analysis_metadata", "analytics", analysis_metadata.function, "_view.html.slim")) || File.exists?(Rails.root.join("app", "views", "analysis_metadata", "analytics", analysis_metadata.function, "_view.html.erb"))
      return "/analysis_metadata/analytics/#{analysis_metadata.function}/view"
    else
      return "/analysis_metadata/analytics/view"
    end
  end
  
end
