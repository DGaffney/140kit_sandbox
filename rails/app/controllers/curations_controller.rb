class CurationsController < ApplicationController
  def index
    @curations = Curation.all
  end
end
