class CurationsController < ApplicationController
  before_filter :login_required, except: [:index, :researcher, :show]
  def index
    @curations = Curation.paginate(:page => params[:page], :per_page => 20)
  end
  
  def search
    @curations = Curation.where(:id => AnalysisMetadata.where(:analytical_offering_id => params[:analytic_id]).collect(&:curation_id)).paginate(:page => params[:page], :per_page => 20) if params[:analytic_id]
    @curations = []
  end
  
  def researcher
    @researcher = Researcher.find_by_user_name(params[:user_name])
    @curations = @researcher.curations
  end
  
  def show
    @curation = Curation.find_by_id(params[:id])
  end

  def validate
    if !curation_is_same?
      @curation = Curation.new
      @datasets = []
      @curation.created_at = Time.now
      @curation.updated_at = @curation.created_at
      @curation.status = "tsv_storing"
      @curation.single_dataset = false
      @curation.name = params[:name] || params[:params]
      @curation.researcher_id = session[:researcher_id]
      if params[:stream_type] == "locations"
        d = Dataset.new
        d.scrape_type = "locations"
        d.params = "#{params[:params]},#{params[:end_time]}"
        d.status = "tsv_storing"
        d.instance_id = "system"
        d.created_at = Time.now
        d.updated_at = Time.now
        d.save!
        @datasets << d
      elsif params[:stream_type] == "term"
        params[:params].split(",").each do |term|
          d = Dataset.new
          d.scrape_type = "track"
          d.params = "#{term},#{params[:end_time]}"
          d.status = "tsv_storing"
          d.instance_id = "system"
          d.created_at = Time.now
          d.updated_at = Time.now
          d.save!
          @datasets << d
        end
      end
      @curation.save!
      @datasets.collect{|d| d.curations << @curation}
    else
      @datasets = @curation.datasets
    end
  end
  
  def curation_is_same?
    @curation = Curation.find_by_name_and_researcher_id(params[:name], session[:researcher_id])
    result = @curation && 
             @curation.datasets.collect{|d| d.params.split(",").first}.sort == params[:name].split(",").sort && 
             @curation.datasets.first.params.split(",").last.to_i == params[:end_time].to_i
    return result
  end
  
  def alter
    #this could probably be done in a much better way.
    @curation = Curation.find(params[:id])
    dataset = @curation.datasets.first
    params[:name] = @curation.datasets.collect{|x| x.params.split(",").first}.join(",")
    case params[:stream_type]
    when "location"
      params[:end_time] = dataset.params.split(",").last.to_i
    when "track"
      params[:end_time] = dataset.params.split(",").last.to_i
    end
    @curation.datasets.collect{|d| d.destroy}
    @curation.destroy
  end
  
  def verify
    @researcher = Researcher.find(session[:researcher_id])
    @curation = Curation.find(params[:id])
    @curation.created_at = Time.now.utc
    @curation.updated_at = @curation.created_at
    @curation.save!
    @curation.datasets.update_all(:created_at => Time.now.utc, :updated_at => Time.now.utc, :instance_id => nil)
    redirect_to researcher_url(@researcher), :notice => "We're running your streams!"
  end
  
  def import
    @curation = Curation.find(params[:id])
    @curation.status = "needs_import"
    @curation.save!
    redirect_to dataset_path(@curation), :notice => "We're Importing the data now!"
  end
  
  def analyze
    @curation = Curation.find(params[:id])
    @researcher = Researcher.find(session[:researcher_id])
    @applied_analytical_offerings = AnalyticalOffering.already_applied(@curation)
    @analysis_metadatas = @curation.analysis_metadatas.paginate(:page => params[:analysis_page], :per_page => 10)
    @analytical_offerings = AnalyticalOffering.available_to_researcher(@researcher)-@applied_analytical_offerings
  end
    
  def archive
    @curation = Curation.find(params[:id])
    @curation.status = "needs_drop"
    @curation.datasets.update_all(:status => "needs_drop")
    @curation.save!
    redirect_to dataset_path(@curation), :notice => "Data has been sent off for a deep freeze."
  end
  
  def new_term
    respond_to do |format|
      format.js { render :template => 'term', :layout => false }
    end
  end
  def new_location
    respond_to do |format|
      format.js { render :template => 'location', :layout => false }
    end
  end
end
