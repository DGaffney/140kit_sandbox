class Curations < Application
  # provides :xml, :yaml, :js

  def index
    limit = params[:limit] || 100
    offset = params[:offset] || 0
    @curations = []
    if params[:dataset_id]
      @curations = Dataset.first(:id => params[:dataset_id]).curations(:limit => limit.to_i, :offset => offset.to_i)
    elsif params[:researcher_id]
      @curations = Researcher.first(:id => params[:researcher_id]).curations(:limit => limit.to_i, :offset => offset.to_i)
    else
      @curations = Curation.all(:archived => false, :limit => limit.to_i, :offset => offset.to_i)
    end
    display @curations
  end

  def show(id)
    @curation = Curation.get(id)
    @analytical_offerings = AnalyticalOffering.all
    raise NotFound unless @curation
    display @curation
  end

  def new
    only_provides :html
    @curation = Curation.new
    display @curation
  end

  def edit(id)
    only_provides :html
    @curation = Curation.get(id)
    raise NotFound unless @curation
    display @curation
  end

  def create(curation)
    @curation = Curation.new(curation)
    if @curation.save
      redirect resource(@curation), :message => {:notice => "Curation was successfully created"}
    else
      message[:error] = "Curation failed to be created"
      render :new
    end
  end

  def update(id, curation)
    @curation = Curation.get(id)
    raise NotFound unless @curation
    if @curation.update(curation)
       redirect resource(@curation), :message => {:notice => "Curation was successfully updated"}
    else
      message[:error] = "Curation failed to be updated"
      display @curation, :edit
    end
  end

  def destroy(id)
    @curation = Curation.get(id)
    raise NotFound unless @curation
    if @curation.destroy
      redirect resource(:curation), :message => {:notice => "Curation was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # Curation
