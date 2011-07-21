class AnalyticalOfferingVariableDescriptors < Application
  # provides :xml, :yaml, :js

  def index
    @analytical_offering_variable_descriptor = AnalyticalOfferingVariableDescriptor.all
    display @analytical_offering_variable_descriptor
  end

  def show(id)
    @analytical_offering_variable_descriptor = AnalyticalOfferingVariableDescriptor.get(id)
    raise NotFound unless @analytical_offering_variable_descriptor
    display @analytical_offering_variable_descriptor
  end

  def new
    only_provides :html
    @analytical_offering_variable_descriptor = AnalyticalOfferingVariableDescriptor.new
    display @analytical_offering_variable_descriptor
  end

  def edit(id)
    only_provides :html
    @analytical_offering_variable_descriptor = AnalyticalOfferingVariableDescriptor.get(id)
    raise NotFound unless @analytical_offering_variable_descriptor
    display @analytical_offering_variable_descriptor
  end

  def create(analytical_offering_variable_descriptor)
    @analytical_offering_variable_descriptor = AnalyticalOfferingVariableDescriptor.new(analytical_offering_variable_descriptor)
    if @analytical_offering_variable_descriptor.save
      redirect resource(@analytical_offering_variable_descriptor), :message => {:notice => "AnalyticalOfferingVariableDescriptor was successfully created"}
    else
      message[:error] = "AnalyticalOfferingVariableDescriptor failed to be created"
      render :new
    end
  end

  def update(id, analytical_offering_variable_descriptor)
    @analytical_offering_variable_descriptor = AnalyticalOfferingVariableDescriptor.get(id)
    raise NotFound unless @analytical_offering_variable_descriptor
    if @analytical_offering_variable_descriptor.update(analytical_offering_variable_descriptor)
       redirect resource(@analytical_offering_variable_descriptor), :message => {:notice => "AnalyticalOfferingVariableDescriptor was successfully updated"}
    else
      message[:error] = "AnalyticalOfferingVariableDescriptor failed to be updated"
      display @analytical_offering_variable_descriptor, :edit
    end
  end

  def destroy(id)
    @analytical_offering_variable_descriptor = AnalyticalOfferingVariableDescriptor.get(id)
    raise NotFound unless @analytical_offering_variable_descriptor
    if @analytical_offering_variable_descriptor.destroy
      redirect resource(:analytical_offering_variable_descriptor), :message => {:notice => "AnalyticalOfferingVariableDescriptor was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # AnalyticalOfferingVariableDescriptor
