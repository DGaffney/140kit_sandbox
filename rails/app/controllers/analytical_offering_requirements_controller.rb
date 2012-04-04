class AnalyticalOfferingRequirementsController < ApplicationController
  before_filter :admin_required, except: [:show, :index]
  def index
    @analytical_offering_requirements = AnalyticalOfferingRequirement.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @analytical_offering_requirements }
    end
  end

  # GET /analytical_offering_requirements/1
  # GET /analytical_offering_requirements/1.json
  def show
    @analytical_offering_requirement = AnalyticalOfferingRequirement.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @analytical_offering_requirement }
    end
  end

  # GET /analytical_offering_requirements/new
  # GET /analytical_offering_requirements/new.json
  def new
    @analytical_offering_requirement = AnalyticalOfferingRequirement.new
    @analytical_offering = AnalyticalOffering.find(params[:id])
    @analytical_offerings = AnalyticalOffering.all-@analytical_offering.dependencies.collect(&:requirement)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @analytical_offering_requirement }
    end
  end

  # GET /analytical_offering_requirements/1/edit
  def edit
    @analytical_offering_requirement = AnalyticalOfferingRequirement.find(params[:id])
  end

  # POST /analytical_offering_requirements
  # POST /analytical_offering_requirements.json
  def create
    @analytical_offering_requirement = AnalyticalOfferingRequirement.new(params[:analytical_offering_requirement])
    respond_to do |format|
      if @analytical_offering_requirement.save
        format.html { redirect_to @analytical_offering_requirement.analytical_offering, notice: 'Analytical offering requirement was successfully created.' }
        format.json { render json: @analytical_offering_requirement, status: :created, location: @analytical_offering_requirement }
      else
        format.html { render action: "new" }
        format.json { render json: @analytical_offering_requirement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /analytical_offering_requirements/1
  # PUT /analytical_offering_requirements/1.json
  def update
    @analytical_offering_requirement = AnalyticalOfferingRequirement.find(params[:id])

    respond_to do |format|
      if @analytical_offering_requirement.update_attributes(params[:analytical_offering_requirement])
        format.html { redirect_to @analytical_offering_requirement, notice: 'Analytical offering requirement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @analytical_offering_requirement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /analytical_offering_requirements/1
  # DELETE /analytical_offering_requirements/1.json
  def destroy
    @analytical_offering_requirement = AnalyticalOfferingRequirement.find(params[:id])
    @analytical_offering = @analytical_offering_requirement.analytical_offering
    @analytical_offering_requirement.destroy

    respond_to do |format|
      format.html { redirect_to request.referer }
      format.json { head :no_content }
    end
  end
end
