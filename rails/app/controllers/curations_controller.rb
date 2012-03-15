class CurationsController < ApplicationController
  def index
    @curations = Curation.all
  end
  
  def researcher
    @researcher = Researcher.find_by_user_name(params[:user_name])
    @curations = @researcher.curations
  end
  
  def validate
    @curation = Curation.new
    @datasets = []
    @curation.created_at = Time.now
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
    end
  end
end
