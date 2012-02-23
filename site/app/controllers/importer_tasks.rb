class ImporterTasks < Application
  # provides :xml, :yaml, :js

  def index
    @importer_task = ImporterTask.all
    display @importer_task
  end

  def show(id)
    @importer_task = ImporterTask.get(id)
    raise NotFound unless @importer_task
    display @importer_task
  end

  def new
    only_provides :html
    @importer_task = ImporterTask.new
    display @importer_task
  end

  def edit(id)
    only_provides :html
    @importer_task = ImporterTask.get(id)
    raise NotFound unless @importer_task
    display @importer_task
  end

  def create(importer_task)
    @importer_task = ImporterTask.new(importer_task)
    if @importer_task.save
      redirect resource(@importer_task), :message => {:notice => "ImporterTask was successfully created"}
    else
      message[:error] = "ImporterTask failed to be created"
      render :new
    end
  end

  def update(id, importer_task)
    @importer_task = ImporterTask.get(id)
    raise NotFound unless @importer_task
    if @importer_task.update(importer_task)
       redirect resource(@importer_task), :message => {:notice => "ImporterTask was successfully updated"}
    else
      message[:error] = "ImporterTask failed to be updated"
      display @importer_task, :edit
    end
  end

  def destroy(id)
    @importer_task = ImporterTask.get(id)
    raise NotFound unless @importer_task
    if @importer_task.destroy
      redirect resource(:importer_task), :message => {:notice => "ImporterTask was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # ImporterTask
