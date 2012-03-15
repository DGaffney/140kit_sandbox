class AnalysisMetadataController < ApplicationController
  # GET /analysis_metadatas
  # GET /analysis_metadatas.json
  def index
    @analysis_metadatas = AnalysisMetadata.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @analysis_metadatas }
    end
  end

  # GET /analysis_metadatas/1
  # GET /analysis_metadatas/1.json
  def show
    @analysis_metadata = AnalysisMetadata.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @analysis_metadata }
    end
  end

  # GET /analysis_metadatas/new
  # GET /analysis_metadatas/new.json
  def new
    @analysis_metadata = AnalysisMetadata.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @analysis_metadata }
    end
  end

  # GET /analysis_metadatas/1/edit
  def edit
    @analysis_metadata = AnalysisMetadata.find(params[:id])
  end

  # POST /analysis_metadatas
  # POST /analysis_metadatas.json
  def create
    @analysis_metadata = AnalysisMetadata.new(params[:analysis_metadata])

    respond_to do |format|
      if @analysis_metadata.save
        format.html { redirect_to @analysis_metadata, notice: 'Analysis metadata was successfully created.' }
        format.json { render json: @analysis_metadata, status: :created, location: @analysis_metadata }
      else
        format.html { render action: "new" }
        format.json { render json: @analysis_metadata.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /analysis_metadatas/1
  # PUT /analysis_metadatas/1.json
  def update
    @analysis_metadata = AnalysisMetadata.find(params[:id])

    respond_to do |format|
      if @analysis_metadata.update_attributes(params[:analysis_metadata])
        format.html { redirect_to @analysis_metadata, notice: 'Analysis metadata was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @analysis_metadata.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /analysis_metadatas/1
  # DELETE /analysis_metadatas/1.json
  def destroy
    @analysis_metadata = AnalysisMetadata.find(params[:id])
    @analysis_metadata.destroy

    respond_to do |format|
      format.html { redirect_to analysis_metadatas_url }
      format.json { head :no_content }
    end
  end
end
