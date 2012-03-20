class AnalysisMetadataController < ApplicationController
  
  def show
    @analysis_metadata = AnalysisMetadata.find(params[:id])
    # @rendered_results = {}#@analysis_metadata.function_class.view(@analysis_metadata.curation, params)
    render :action => "show"
  end
  
  def graph
    @analysis_metadata = AnalysisMetadata.find(params[:id])
    @graph = Graph.find(params[:graph_id])
    respond_to do |format|
      format.js { render :template => analysis_metadata_partial_path(@analysis_metadata), :layout => false }
    end
  end

  def analysis_metadata_partial_path(analysis_metadata)
    if File.exists?(Rails.root.join("app", "views", "analysis_metadata", "analytics", analysis_metadata.function, "_#{analysis_metadata.function}.js.erb"))
      return "/analysis_metadata/analytics/#{analysis_metadata.function}/graph"
    else
      return "/analysis_metadata/analytics/graph"
    end
  end
  
end
