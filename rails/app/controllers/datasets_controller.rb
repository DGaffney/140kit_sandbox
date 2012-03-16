class DatasetsController < ApplicationController
  def index
    @datasets = Dataset.all
  end
  
end
