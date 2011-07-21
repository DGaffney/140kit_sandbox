class Researchers < Application
  # provides :xml, :yaml, :js

  def index
    @researcher = Researcher.all
    display @researcher
  end

  def show(user_name)
    @researcher = Researcher.first(:user_name => user_name)
    @curations = @researcher.curations
    raise NotFound unless @researcher
    display @researcher
  end

  def new
    only_provides :html
    @researcher = Researcher.new
    display @researcher
  end

  def edit(id)
    only_provides :html
    @researcher = Researcher.get(id)
    raise NotFound unless @researcher
    display @researcher
  end

  def create(researcher)
    @researcher = Researcher.new(researcher)
    if @researcher.save
      redirect resource(@researcher), :message => {:notice => "Researcher was successfully created"}
    else
      message[:error] = "Researcher failed to be created"
      render :new
    end
  end

  def update(id, researcher)
    @researcher = Researcher.get(id)
    raise NotFound unless @researcher
    if @researcher.update(researcher)
       redirect resource(@researcher), :message => {:notice => "Researcher was successfully updated"}
    else
      message[:error] = "Researcher failed to be updated"
      display @researcher, :edit
    end
  end

  def destroy(id)
    @researcher = Researcher.get(id)
    raise NotFound unless @researcher
    if @researcher.destroy
      redirect resource(:researcher), :message => {:notice => "Researcher was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # Researcher
