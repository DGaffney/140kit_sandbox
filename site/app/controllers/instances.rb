class Instances < Application
  # provides :xml, :yaml, :js

  def index
    @instance = Instance.all
    display @instance
  end

  def show(id)
    @instance = Instance.get(id)
    raise NotFound unless @instance
    display @instance
  end

  def new
    only_provides :html
    @instance = Instance.new
    display @instance
  end

  def edit(id)
    only_provides :html
    @instance = Instance.get(id)
    raise NotFound unless @instance
    display @instance
  end

  def create(instance)
    @instance = Instance.new(instance)
    if @instance.save
      redirect resource(@instance), :message => {:notice => "Instance was successfully created"}
    else
      message[:error] = "Instance failed to be created"
      render :new
    end
  end

  def update(id, instance)
    @instance = Instance.get(id)
    raise NotFound unless @instance
    if @instance.update(instance)
       redirect resource(@instance), :message => {:notice => "Instance was successfully updated"}
    else
      message[:error] = "Instance failed to be updated"
      display @instance, :edit
    end
  end

  def destroy(id)
    @instance = Instance.get(id)
    raise NotFound unless @instance
    if @instance.destroy
      redirect resource(:instance), :message => {:notice => "Instance was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # Instance
