class AnalyticalOfferingVariables < Application
  # provides :xml, :yaml, :js

  def index
    @analytical_offering_variable = AnalyticalOfferingVariable.all
    display @analytical_offering_variable
  end

  def show(id)
    @analytical_offering_variable = AnalyticalOfferingVariable.get(id)
    raise NotFound unless @analytical_offering_variable
    display @analytical_offering_variable
  end

  def new
    only_provides :html
    @analytical_offering_variable = AnalyticalOfferingVariable.new
    display @analytical_offering_variable
  end

  def edit(id)
    only_provides :html
    @analytical_offering_variable = AnalyticalOfferingVariable.get(id)
    raise NotFound unless @analytical_offering_variable
    display @analytical_offering_variable
  end

  def create(analytical_offering_variable)
    @analytical_offering_variable = AnalyticalOfferingVariable.new(analytical_offering_variable)
    if @analytical_offering_variable.save
      redirect resource(@analytical_offering_variable), :message => {:notice => "AnalyticalOfferingVariable was successfully created"}
    else
      message[:error] = "AnalyticalOfferingVariable failed to be created"
      render :new
    end
  end

  def update(id, analytical_offering_variable)
    @analytical_offering_variable = AnalyticalOfferingVariable.get(id)
    raise NotFound unless @analytical_offering_variable
    if @analytical_offering_variable.update(analytical_offering_variable)
       redirect resource(@analytical_offering_variable), :message => {:notice => "AnalyticalOfferingVariable was successfully updated"}
    else
      message[:error] = "AnalyticalOfferingVariable failed to be updated"
      display @analytical_offering_variable, :edit
    end
  end

  def destroy(id)
    @analytical_offering_variable = AnalyticalOfferingVariable.get(id)
    raise NotFound unless @analytical_offering_variable
    if @analytical_offering_variable.destroy
      redirect resource(:analytical_offering_variable), :message => {:notice => "AnalyticalOfferingVariable was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # AnalyticalOfferingVariable
