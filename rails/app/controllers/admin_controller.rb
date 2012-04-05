class AdminController < ApplicationController
  before_filter :admin_required
  def panel
    @page_title = "Panel"
  end
  
end
