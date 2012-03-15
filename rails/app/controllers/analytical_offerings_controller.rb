class AnalyticalOfferingsController < ApplicationController
  # GET /analytical_offerings
  # GET /analytical_offerings.json
  def index
    @analytical_offerings = AnalyticalOffering.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @analytical_offerings }
    end
  end

  # GET /analytical_offerings/1
  # GET /analytical_offerings/1.json
  def show
    @analytical_offering = AnalyticalOffering.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @analytical_offering }
    end
  end

  # GET /analytical_offerings/new
  # GET /analytical_offerings/new.json
  def new
    @analytical_offering = AnalyticalOffering.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @analytical_offering }
    end
  end

  # GET /analytical_offerings/1/edit
  def edit
    @analytical_offering = AnalyticalOffering.find(params[:id])
  end

  # POST /analytical_offerings
  # POST /analytical_offerings.json
  def create
    @analytical_offering = AnalyticalOffering.new(params[:analytical_offering])

    respond_to do |format|
      if @analytical_offering.save
        format.html { redirect_to @analytical_offering, notice: 'Analytical offering was successfully created.' }
        format.json { render json: @analytical_offering, status: :created, location: @analytical_offering }
      else
        format.html { render action: "new" }
        format.json { render json: @analytical_offering.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /analytical_offerings/1
  # PUT /analytical_offerings/1.json
  def update
    @analytical_offering = AnalyticalOffering.find(params[:id])

    respond_to do |format|
      if @analytical_offering.update_attributes(params[:analytical_offering])
        format.html { redirect_to @analytical_offering, notice: 'Analytical offering was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @analytical_offering.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /analytical_offerings/1
  # DELETE /analytical_offerings/1.json
  def destroy
    @analytical_offering = AnalyticalOffering.find(params[:id])
    @analytical_offering.destroy

    respond_to do |format|
      format.html { redirect_to analytical_offerings_url }
      format.json { head :no_content }
    end
  end
end
