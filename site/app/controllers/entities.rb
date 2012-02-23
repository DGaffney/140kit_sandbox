class Entities < Application
  # provides :xml, :yaml, :js

  def index
    limit = params[:limit] || 100
    offset = params[:offset] || 0
    @entities = []
    if params[:dataset_id]
      @entities = Entity.all(:dataset_id => params[:dataset_id], :limit => limit.to_i, :offset => offset.to_i)
    elsif params[:curation_id]
      @entities = Entity.all(:dataset_id => Curation.first(:id => params[:curation_id]).datasets.collect(&:id), :limit => limit.to_i, :offset => offset.to_i)
    elsif params[:entitie_id]
      @entities = Entity.all(:entitie_id => params[:entitie_id], :limit => limit.to_i, :offset => offset.to_i)
    else
      @entities = Entity.all(:limit => limit.to_i, :offset => offset.to_i)
    end
    display @entities
  end

  def show(id)
    @entity = Entity.get(id)
    raise NotFound unless @entity
    display @entity
  end

  def new
    only_provides :html
    @entity = Entity.new
    display @entity
  end

  def edit(id)
    only_provides :html
    @entity = Entity.get(id)
    raise NotFound unless @entity
    display @entity
  end

  def create(entity)
    @entity = Entity.new(entity)
    if @entity.save
      redirect resource(@entity), :message => {:notice => "Entity was successfully created"}
    else
      message[:error] = "Entity failed to be created"
      render :new
    end
  end

  def update(id, entity)
    @entity = Entity.get(id)
    raise NotFound unless @entity
    if @entity.update(entity)
       redirect resource(@entity), :message => {:notice => "Entity was successfully updated"}
    else
      message[:error] = "Entity failed to be updated"
      display @entity, :edit
    end
  end

  def destroy(id)
    @entity = Entity.get(id)
    raise NotFound unless @entity
    if @entity.destroy
      redirect resource(:entity), :message => {:notice => "Entity was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # Entity
