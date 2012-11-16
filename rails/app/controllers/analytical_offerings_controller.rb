class AnalyticalOfferingsController < ApplicationController
  before_filter :admin_required, except: [:show, :index, :add, :validate]
  before_filter :login_required, only: [:add, :validate]
  def show
    @analytical_offering = AnalyticalOffering.find(params[:id])
    @dependencies = AnalyticalOfferingRequirement.where(:analytical_offering_id => @analytical_offering.id).order(:position).paginate(:page => params[:requirement_page], :per_page => 4)
    @analytical_offering_variables = AnalyticalOfferingVariableDescriptor.where(:analytical_offering_id => @analytical_offering.id).order(:position).paginate(:page => params[:variable_page], :per_page => 1)
    @page_title = "Analytics: #{@analytical_offering.title}"
  end
  
  def index
    @analytical_offerings = AnalyticalOffering.where(:enabled => true).paginate(:page => params[:page], :per_page => 10)
    @page_title = "Analytics"
  end

  def new
    @analytical_offering = AnalyticalOffering.new
    @page_title = "New Analytic"
  end
  
  def create
    @analytical_offering = AnalyticalOffering.new(params[:analytical_offering])

    respond_to do |format|
      if @analytical_offering.save
        format.html { redirect_to @analytical_offering, notice: 'Analytical Offering was successfully created.' }
        format.json { render json: @analytical_offering, status: :created, location: @analytical_offering }
      else
        format.html { render action: "new" }
        format.json { render json: @analytical_offering.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @analytical_offering = AnalyticalOffering.find(params[:id])
    @page_title = "Analytics: Editing #{@analytical_offering.title}"
  end
  
  def update
    @analytical_offering = AnalyticalOffering.find(params[:id])

    respond_to do |format|
      if @analytical_offering.update_attributes(params[:analytical_offering])
        format.html { redirect_to @analytical_offering, notice: 'Analytical Offering was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @analytical_offering.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @analytical_offering = AnalyticalOffering.find(params[:id])
    @analytical_offering.destroy

    respond_to do |format|
      format.html { redirect_to analytical_offerings_url }
      format.json { head :no_content }
    end
  end

  def add
    current_user
    @curation = Curation.find(params[:curation_id])
    @analytical_offering = AnalyticalOffering.find(params[:id])
    @analysis_metadata = AnalysisMetadata.new(:curation_id => params[:curation_id], :analytical_offering_id => params[:id], :ready => false)
  end
  
  def validate
    @curation = Curation.find(params[:curation_id])
    @analytical_offering = AnalyticalOffering.find(params[:id])
    @analysis_metadata = AnalysisMetadata.new(:curation_id => params[:curation_id], :analytical_offering_id => params[:id], :ready => false)
    @analysis_metadata.save!
    redirect_url = []
    validation_results = {}
    failed = false
    variables = []
    @analysis_metadata.analytical_offering.variables.each do |variable|
      aov = AnalyticalOfferingVariable.new
      aov.analytical_offering_variable_descriptor_id = variable.id
      aov.analysis_metadata_id = @analysis_metadata.id
      aov.value = params["aovd"][aov.name]
      result = @analysis_metadata.verify_variable(variable, aov.value)
      failed = !result[:reason].nil? && !result[:reason].empty?
      params["aov_"+variable.name+"_error"] = result[:reason]
      params["aov_"+variable.name] = result[:variable]
      variables << aov
    end
    variables.each do |variable|
      variable.save!
    end
    if failed
      @analysis_metadata.variables.each do |var|
        var.destroy
      end
      @analysis_metadata.destroy
      flash[:notice] = "Please check your settings again, sorry."
      render :action => 'add' and return      
    end
    validation_results.merge!(@analysis_metadata.verify_absolute_uniqueness)
    if validation_results[:success]
      flash[:success] = "Analytic Added!"
      @analysis_metadata.ready = true
      @analysis_metadata.save!
      redirect_to analyze_dataset_path(@curation) and return
    else
      @analysis_metadata.variables.each do |var|
        var.destroy
      end
      @analysis_metadata.destroy
      flash[:notice] = "You actually already added this analytic, so you don't have to worry!"
      render :action => 'add' and return
      #add_analytical_offering_path(@analytical_offering, @curation) and return
    end
  end
end
