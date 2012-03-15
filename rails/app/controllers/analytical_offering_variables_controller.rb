class AnalyticalOfferingVariablesController < ApplicationController
  # GET /analytical_offering_variables
  # GET /analytical_offering_variables.json
  def index
    @analytical_offering_variables = AnalyticalOfferingVariable.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @analytical_offering_variables }
    end
  end

  # GET /analytical_offering_variables/1
  # GET /analytical_offering_variables/1.json
  def show
    @analytical_offering_variable = AnalyticalOfferingVariable.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @analytical_offering_variable }
    end
  end

  # GET /analytical_offering_variables/new
  # GET /analytical_offering_variables/new.json
  def new
    @analytical_offering_variable = AnalyticalOfferingVariable.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @analytical_offering_variable }
    end
  end

  # GET /analytical_offering_variables/1/edit
  def edit
    @analytical_offering_variable = AnalyticalOfferingVariable.find(params[:id])
  end

  # POST /analytical_offering_variables
  # POST /analytical_offering_variables.json
  def create
    @analytical_offering_variable = AnalyticalOfferingVariable.new(params[:analytical_offering_variable])

    respond_to do |format|
      if @analytical_offering_variable.save
        format.html { redirect_to @analytical_offering_variable, notice: 'Analytical offering variable was successfully created.' }
        format.json { render json: @analytical_offering_variable, status: :created, location: @analytical_offering_variable }
      else
        format.html { render action: "new" }
        format.json { render json: @analytical_offering_variable.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /analytical_offering_variables/1
  # PUT /analytical_offering_variables/1.json
  def update
    @analytical_offering_variable = AnalyticalOfferingVariable.find(params[:id])

    respond_to do |format|
      if @analytical_offering_variable.update_attributes(params[:analytical_offering_variable])
        format.html { redirect_to @analytical_offering_variable, notice: 'Analytical offering variable was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @analytical_offering_variable.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /analytical_offering_variables/1
  # DELETE /analytical_offering_variables/1.json
  def destroy
    @analytical_offering_variable = AnalyticalOfferingVariable.find(params[:id])
    @analytical_offering_variable.destroy

    respond_to do |format|
      format.html { redirect_to analytical_offering_variables_url }
      format.json { head :no_content }
    end
  end
end
