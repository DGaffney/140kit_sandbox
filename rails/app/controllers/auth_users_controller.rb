class AuthUsersController < ApplicationController
  before_filter :admin_required
  def index
    @auth_users = AuthUser.paginate(:page => params[:page], :per_page => 10)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @auth_users }
    end
  end

  def show
    @auth_user = AuthUser.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @auth_user }
    end
  end

  def new
    @auth_user = AuthUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @auth_user }
    end
  end

  def edit
    @auth_user = AuthUser.find(params[:id])
  end

  def create
    @auth_user = AuthUser.new(params[:auth_user])

    respond_to do |format|
      if @auth_user.save
        format.html { redirect_to @auth_user, notice: 'Auth user was successfully created.' }
        format.json { render json: @auth_user, status: :created, location: @auth_user }
      else
        format.html { render action: "new" }
        format.json { render json: @auth_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @auth_user = AuthUser.find(params[:id])

    respond_to do |format|
      if @auth_user.update_attributes(params[:auth_user])
        format.html { redirect_to @auth_user, notice: 'Auth user was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @auth_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @auth_user = AuthUser.find(params[:id])
    @auth_user.destroy

    respond_to do |format|
      format.html { redirect_to auth_users_url }
      format.json { head :no_content }
    end
  end
end
