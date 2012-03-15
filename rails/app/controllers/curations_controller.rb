class CurationsController < ApplicationController
  def index
    @curations = Curation.all
  end
  
  def researcher
    @researcher = Researcher.find_by_user_name(params[:user_name])
    @curations = @researcher.curations
    debugger
    gg = ""
  end
end
