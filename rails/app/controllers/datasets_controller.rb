class DatasetsController < ApplicationController
  def index
    @datasets = Dataset.all
  end
  
  def archive
    debugger
    
  end
end
