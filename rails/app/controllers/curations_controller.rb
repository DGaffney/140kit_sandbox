class CurationsController < ApplicationController
  def index
    @curations = Curation.all
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
      @curation.name = params[:name]
      @curation.researcher_id = session[:researcher_id]
      @curation.save!
      params[:name].split(",").each do |term|
        d = Dataset.new
        d.scrape_type = "track"
        d.params = "#{term},#{params[:end_time]}"
        d.status = "tsv_storing"
        d.instance_id = "system"
        d.save!
        @datasets << d
      end
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
    case dataset.scrape_type
    when "track"
      params[:end_time] = dataset.params.split(",").last.to_i
    end
    @curation.datasets.collect{|d| d.destroy}
    @curation.destroy
  end
  
  def verify
    @researcher = Researcher.find(session[:researcher_id])
    @curation = Curation.find(params[:id])
    @curation.datasets.each do |d|
      d.instance_id = nil
      d.save!
    end
    redirect_to researcher_url(@researcher), :notice => "We're running your streams!"
  end
  
  def import
    @curation = Curation.find(params[:id])
    @curation.status = "needs_import"
    @curation.save!
  end
end
