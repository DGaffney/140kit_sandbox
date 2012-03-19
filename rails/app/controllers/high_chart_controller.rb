class HighChartController < ApplicationController
  
  def graph
    @graph = Graph.find(params[:id])
    respond_to do |format|
      format.js {render :action => @graph.analysis_metadata.function}
    end
  end
end
