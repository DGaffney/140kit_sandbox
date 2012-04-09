class ResearchersController < ApplicationController
  before_filter :login_required, except: [:index, :show]
  before_filter :admin_required, only: [:destroy, :panel]

  def index
    @page_title = "Researchers"
    #removed dope-ass join because paginate wouldn't play nice.
    @researchers = Researcher.where(:hidden_account => false).paginate(:page => params[:page], :per_page => 16)
  end

  def dashboard
    @page_title = "Dashboard"
    @researcher = Researcher.find(current_user.id)
    @curations = @researcher.curations.where("status != 'hidden'").paginate(:page => params[:page], :per_page => 10, :order => "id desc")
    # @curations = @researcher.curations.order(:created_at)
  end

  def show
    @researcher = Researcher.where(user_name: params[:user_name]).first
    @page_title = @researcher.name
    @curations = @researcher.curations.where("status != 'hidden'").paginate(:page => params[:page], :per_page => 20, :order => "id desc", :limit => 10)
  end

  def edit
    @researcher = Researcher.find_by_user_name(params[:user_name])
    @page_title = "Editing "+@researcher.name
  end

  def new
    # NOTE: Not your typical 'new' because the user is already created
    @researcher = Researcher.find_by_user_name(params[:user_name])
  end

  def update
    @researcher = Researcher.find_by_user_name(params[:user_name], select: [:id, :user_name])
    respond_to do |format|
      if @researcher.update_attributes(params[:researcher])
        format.html { redirect_to @researcher, flash: { success: "Your info has been updated." } }
        format.js
      else
        format.html { render action: 'edit', flash: { error: @reseacher.errors } }
        format.js
      end
    end
  end

  def destroy
    @researcher = Researcher.find_by_user_name(params[:user_name], select: [:id])
    respond_to do |format|
      if @researcher.destroy
        format.html { redirect_to @researcher, notice: "Researcher successfully updated." }
        format.js
      else
        format.html { render action: 'edit' }
        format.js
      end
    end
  end
  
  def panel
  end
  
  def upgrade
    @researcher = Researcher.find_by_user_name(params[:user_name])
    roles = Setting.find_by_name("roles").actual_value
    @researcher.role = roles[roles.index(@researcher.role)+1]
    @researcher.upgrade_requested = false
    @researcher.save!
    redirect_to request.referer
  end

  def request_upgrade
    @researcher = Researcher.find_by_user_name(params[:user_name])
    @researcher.upgrade_requested = true
    @researcher.save!
    redirect_to request.referer
  end
end
