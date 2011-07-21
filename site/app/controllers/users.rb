class Users < Application
  # provides :xml, :yaml, :js

  def index(limit=100, offset=0)
    @users = []
    if params[:dataset_id]
      @users = User.all(:dataset_id => params[:dataset_id], :limit => limit, :offset => offset)
    elsif params[:curation_id]
      @users = User.all(:dataset_id => Curation.first(:id => params[:curation_id]).datasets.collect(&:id), :limit => limit, :offset => offset)
    elsif params[:user_id]
      @users = User.all(:user_id => params[:user_id], :limit => limit, :offset => offset)
    else
      @users = User.all(:limit => limit, :offset => offset)
    end
    display @users
  end

  def show(id, limit=100, offset=0)
    useful_parameters = ["dataset_id", "curation_id"]
    passed_parameters = Mash[params.select{|x,y| useful_parameters.include?(x)}]
    @user = User.first({:id => id}.merge(passed_parameters))
    @tweets = Tweet.all({:user_id => @user.twitter_id}.merge(passed_parameters))
    raise NotFound unless @user
    display @user
  end

  def new
    only_provides :html
    @user = User.new
    display @user
  end

  def edit(id)
    only_provides :html
    @user = User.get(id)
    raise NotFound unless @user
    display @user
  end

  def create(user)
    @user = User.new(user)
    if @user.save
      redirect resource(@user), :message => {:notice => "User was successfully created"}
    else
      message[:error] = "User failed to be created"
      render :new
    end
  end

  def update(id, user)
    @user = User.get(id)
    raise NotFound unless @user
    if @user.update(user)
       redirect resource(@user), :message => {:notice => "User was successfully updated"}
    else
      message[:error] = "User failed to be updated"
      display @user, :edit
    end
  end

  def destroy(id)
    @user = User.get(id)
    raise NotFound unless @user
    if @user.destroy
      redirect resource(:user), :message => {:notice => "User was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # User
