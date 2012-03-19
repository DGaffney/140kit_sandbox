class AnalysisMetadataController < ApplicationController
  
  def show
    @analysis_metadata = AnalysisMetadata.find(params[:id])
    debugger
    @rendered_results = @analysis_metadata.function_class.view(@analysis_metadata.curation)
  end
end
