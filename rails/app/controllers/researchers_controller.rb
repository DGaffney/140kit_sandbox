class ResearchersController < ApplicationController
  before_filter :login_required, except: [:index, :show]

  def index
    @page_title = "Researchers"
    # select researchers.id, count(curations.id) from researchers left join curations on curations.researcher_id = researchers.id group by researchers.id;
    @researchers = Researcher.find( :all,
                                    limit: 100,
                                    joins: "left join `curations` on curations.researcher_id = researchers.id",
                                    select: "researchers.id, researchers.name, researchers.user_name, count(curations.id) as `curations_count`",
                                    conditions: { hidden_account: false },
                                    group: "researchers.id"
                                  )
    # @researchers = Researcher.select([:id, :name, :user_name]).where(:hidden_account => false)
  end

  def show
    @researcher = Researcher.where(user_name: params[:user_name]).first
    @curations = @researcher.curations.select([:id, :name, :created_at])
  end

  def edit
    @researcher = Researcher.find_by_user_name(params[:user_name], select: [:id, :name, :user_name])
  end

  def update
    @researcher = Researcher.find_by_user_name(params[:user_name], select: [:id, :user_name])
    respond_to do |format|
      if @researcher.update_attributes(params[:researcher])
        format.html { redirect_to @researcher, notice: "Researcher successfully updated." }
        format.js
      else
        format.html { render action: 'edit' }
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
end
