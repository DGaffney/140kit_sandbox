class AnalyticalOfferingsController < ApplicationController
  def show
    @analytical_offering = AnalyticalOffering.find(params[:id])
  end
  
  def add
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
    @analysis_metadata.set_variables.each do |variable|
      variable.save!
      value = params["aov_"+variable.name]
      result = @analysis_metadata.verify_variable(variable, value )
      failed = !result[:reason].nil? && !result[:reason].empty?
      params["aov_"+variable.name+"_error"] = result[:reason]
      params["aov_"+variable.name] = result[:variable]
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
      flash[:notice] = "Analytic Added!"
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
