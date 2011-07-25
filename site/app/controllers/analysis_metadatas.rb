class AnalysisMetadatas < Application
  # provides :xml, :yaml, :js

  def index
    @analysis_metadatas = AnalysisMetadata.all
    display @analysis_metadatas
  end

  def show(id)
    @analysis_metadata = AnalysisMetadata.get(id)
    raise NotFound unless @analysis_metadata
    self.class.layout("analysis")
    display @analysis_metadata
  end

  def new
    only_provides :html
    @analysis_metadata = AnalysisMetadata.new
    @analytical_offering = AnalyticalOffering.get(params[:analytical_offering_id])
    @curation = Curation.get(params[:curation_id])
    @analysis_metadata.analytical_offering_id = @analytical_offering.id
    @analysis_metadata.curation_id = @curation.id
    display @analysis_metadata
  end

  def edit(id)
    only_provides :html
    @analysis_metadata = AnalysisMetadata.get(id)
    raise NotFound unless @analysis_metadata
    display @analysis_metadata
  end

  def verify
    debugger
    @analytical_offering = AnalyticalOffering.get(params[:analytical_offering_id])
    @curation = Curation.get(params[:curation_id])
    param_vals = Hash[params.select{|x,y|x.include?("var")}]
    analytical_offering_variable_descriptors = AnalyticalOfferingVariableDescriptor.all(:id => param_vals.keys.collect{|x| x.gsub("var_", "")}).sort{|x,y| x.position<=>y.position}
    analytical_offering_variable_descriptor = analytical_offering_variable_descriptors.first
    @analysis_metadata = AnalysisMetadata.new(:analytical_offering_id => @analytical_offering.id, :curation_id => @curation.id)
    @reasons = []
    analytical_offering_variable_descriptors.each do |analytical_offering_variable_descriptor|
      @reasons << @analysis_metadata.verify_variable(analytical_offering_variable_descriptor, param_vals["var_#{analytical_offering_variable_descriptor.id}"])
    end
    unique = @analysis_metadata.verify_uniqueness
    params[:verified] = @reasons.collect{|reason| reason[:reason]}.compact.empty? && unique
    params[:unique] = unique
    if params[:verified]
      @analysis_metadata.save!
      @reasons.each do |reason|
        analytical_offering_variable = AnalyticalOfferingVariable.new(:analytical_offering_variable_descriptor_id => reason[:analytical_offering_variable_descriptor_id], :analysis_metadata_id => @analysis_metadata.id, :value => reason[:variable])
        analytical_offering_variable.save!
      end
      redirect resource(@curation), :message => {:notice => "Analytic has been successfully added"}
    else
      render :new
    end
  end

  def create(analysis_metadata)
    @analysis_metadata = AnalysisMetadata.new(analysis_metadata)
    if @analysis_metadata.save
      redirect resource(@analysis_metadata), :message => {:notice => "AnalysisMetadata was successfully created"}
    else
      message[:error] = "AnalysisMetadata failed to be created"
      render :new
    end
  end

  def update(id, analysis_metadata)
    @analysis_metadata = AnalysisMetadata.get(id)
    raise NotFound unless @analysis_metadata
    if @analysis_metadata.update(analysis_metadata)
       redirect resource(@analysis_metadata), :message => {:notice => "AnalysisMetadata was successfully updated"}
    else
      message[:error] = "AnalysisMetadata failed to be updated"
      display @analysis_metadata, :edit
    end
  end

  def destroy(id)
    @analysis_metadata = AnalysisMetadata.get(id)
    raise NotFound unless @analysis_metadata
    if @analysis_metadata.destroy
      redirect resource(:analysis_metadatas), :message => {:notice => "AnalysisMetadata was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # AnalysisMetadatas
