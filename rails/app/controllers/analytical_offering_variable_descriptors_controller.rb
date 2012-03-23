class AnalyticalOfferingVariableDescriptorsController < ApplicationController
  # GET /analytical_offering_variable_descriptors
  # GET /analytical_offering_variable_descriptors.json
  def index
    @analytical_offering_variable_descriptors = AnalyticalOfferingVariableDescriptor.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @analytical_offering_variable_descriptors }
    end
  end

  # GET /analytical_offering_variable_descriptors/1
  # GET /analytical_offering_variable_descriptors/1.json
  def show
    @analytical_offering_variable_descriptor = AnalyticalOfferingVariableDescriptor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @analytical_offering_variable_descriptor }
    end
  end

  # GET /analytical_offering_variable_descriptors/new
  # GET /analytical_offering_variable_descriptors/new.json
  def new
    @analytical_offering_variable_descriptor = AnalyticalOfferingVariableDescriptor.new
    @analytical_offering = AnalyticalOffering.find(params[:id])
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @analytical_offering_variable_descriptor }
    end
  end

  # GET /analytical_offering_variable_descriptors/1/edit
  def edit
    @analytical_offering_variable_descriptor = AnalyticalOfferingVariableDescriptor.find(params[:id])
  end

  # POST /analytical_offering_variable_descriptors
  # POST /analytical_offering_variable_descriptors.json
  def create
    @analytical_offering_variable_descriptor = AnalyticalOfferingVariableDescriptor.new(params[:analytical_offering_variable_descriptor])

    respond_to do |format|
      if @analytical_offering_variable_descriptor.save
        format.html { redirect_to @analytical_offering_variable_descriptor.analytical_offering, notice: 'Analytical offering variable descriptor was successfully created.' }
        format.json { render json: @analytical_offering_variable_descriptor, status: :created, location: @analytical_offering_variable_descriptor }
      else
        format.html { render action: "new" }
        format.json { render json: @analytical_offering_variable_descriptor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /analytical_offering_variable_descriptors/1
  # PUT /analytical_offering_variable_descriptors/1.json
  def update
    @analytical_offering_variable_descriptor = AnalyticalOfferingVariableDescriptor.find(params[:id])

    respond_to do |format|
      if @analytical_offering_variable_descriptor.update_attributes(params[:analytical_offering_variable_descriptor])
        format.html { redirect_to @analytical_offering_variable_descriptor, notice: 'Analytical offering variable descriptor was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @analytical_offering_variable_descriptor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /analytical_offering_variable_descriptors/1
  # DELETE /analytical_offering_variable_descriptors/1.json
  def destroy
    @analytical_offering_variable_descriptor = AnalyticalOfferingVariableDescriptor.find(params[:id])
    @analytical_offering_variable_descriptor.destroy

    respond_to do |format|
      format.html { redirect_to analytical_offering_variable_descriptors_url }
      format.json { head :no_content }
    end
  end
end
