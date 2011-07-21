class WorkerDescriptions < Application
  # provides :xml, :yaml, :js

  def index
    @worker_descriptions = WorkerDescription.all
    display @worker_descriptions
  end

  def show(id)
    @worker_description = WorkerDescription.get(id)
    raise NotFound unless @worker_description
    display @worker_description
  end

  def new
    only_provides :html
    @worker_description = WorkerDescription.new
    display @worker_description
  end

  def edit(id)
    only_provides :html
    @worker_description = WorkerDescription.get(id)
    raise NotFound unless @worker_description
    display @worker_description
  end

  def create(worker_description)
    @worker_description = WorkerDescription.new(worker_description)
    if @worker_description.save
      redirect resource(@worker_description), :message => {:notice => "WorkerDescription was successfully created"}
    else
      message[:error] = "WorkerDescription failed to be created"
      render :new
    end
  end

  def update(id, worker_description)
    @worker_description = WorkerDescription.get(id)
    raise NotFound unless @worker_description
    if @worker_description.update(worker_description)
       redirect resource(@worker_description), :message => {:notice => "WorkerDescription was successfully updated"}
    else
      message[:error] = "WorkerDescription failed to be updated"
      display @worker_description, :edit
    end
  end

  def destroy(id)
    @worker_description = WorkerDescription.get(id)
    raise NotFound unless @worker_description
    if @worker_description.destroy
      redirect resource(:worker_descriptions), :message => {:notice => "WorkerDescription was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # WorkerDescriptions
