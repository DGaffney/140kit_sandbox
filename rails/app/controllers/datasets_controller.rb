class DatasetsController < ApplicationController
  def index
    @datasets = Dataset.all
  end
  
  def show
    @curation = Curation.find_by_id(params[:id])
  end
end
