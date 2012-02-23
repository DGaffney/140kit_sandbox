class AnalyticalOfferings < Application
  # provides :xml, :yaml, :js

  def index
    @analytical_offering = AnalyticalOffering.all
    display @analytical_offering
  end

  def show(id)
    @analytical_offering = AnalyticalOffering.get(id)
    raise NotFound unless @analytical_offering
    display @analytical_offering
  end

  def new
    only_provides :html
    @analytical_offering = AnalyticalOffering.new
    display @analytical_offering
  end

  def edit(id)
    only_provides :html
    @analytical_offering = AnalyticalOffering.get(id)
    raise NotFound unless @analytical_offering
    display @analytical_offering
  end

  def create(analytical_offering)
    @analytical_offering = AnalyticalOffering.new(analytical_offering)
    if @analytical_offering.save
      redirect resource(@analytical_offering), :message => {:notice => "AnalyticalOffering was successfully created"}
    else
      message[:error] = "AnalyticalOffering failed to be created"
      render :new
    end
  end

  def update(id, analytical_offering)
    @analytical_offering = AnalyticalOffering.get(id)
    raise NotFound unless @analytical_offering
    if @analytical_offering.update(analytical_offering)
       redirect resource(@analytical_offering), :message => {:notice => "AnalyticalOffering was successfully updated"}
    else
      message[:error] = "AnalyticalOffering failed to be updated"
      display @analytical_offering, :edit
    end
  end

  def destroy(id)
    @analytical_offering = AnalyticalOffering.get(id)
    raise NotFound unless @analytical_offering
    if @analytical_offering.destroy
      redirect resource(:analytical_offering), :message => {:notice => "AnalyticalOffering was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # AnalyticalOffering
