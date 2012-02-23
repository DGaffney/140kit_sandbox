class AuthUsers < Application
  # provides :xml, :yaml, :js

  def index
    @auth_user = AuthUser.all
    display @auth_user
  end

  def show(id)
    @auth_user = AuthUser.get(id)
    raise NotFound unless @auth_user
    display @auth_user
  end

  def new
    only_provides :html
    @auth_user = AuthUser.new
    display @auth_user
  end

  def edit(id)
    only_provides :html
    @auth_user = AuthUser.get(id)
    raise NotFound unless @auth_user
    display @auth_user
  end

  def create(auth_user)
    @auth_user = AuthUser.new(auth_user)
    if @auth_user.save
      redirect resource(@auth_user), :message => {:notice => "AuthUser was successfully created"}
    else
      message[:error] = "AuthUser failed to be created"
      render :new
    end
  end

  def update(id, auth_user)
    @auth_user = AuthUser.get(id)
    raise NotFound unless @auth_user
    if @auth_user.update(auth_user)
       redirect resource(@auth_user), :message => {:notice => "AuthUser was successfully updated"}
    else
      message[:error] = "AuthUser failed to be updated"
      display @auth_user, :edit
    end
  end

  def destroy(id)
    @auth_user = AuthUser.get(id)
    raise NotFound unless @auth_user
    if @auth_user.destroy
      redirect resource(:auth_user), :message => {:notice => "AuthUser was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # AuthUser
