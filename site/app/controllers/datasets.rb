class Datasets < Application
  # provides :xml, :yaml, :js
  before :ensure_authenticated, :exclude => [:show, :index]
  def index
    limit = params[:limit] || 100
    offset = params[:offset] || 0
    useful_parameters = ["curation_id"]
    passed_parameters = Mash[params.select{|x,y| useful_parameters.include?(x)}]
    @datasets = []
    if passed_parameters[:curation_id]
      @datasets = Curation.get(passed_parameters[:curation_id]).datasets
    else
     @datasets = Dataset.all({:limit => limit.to_i, :offset => offset.to_i}.merge(passed_parameters))
    end 
    display @datasets
  end

  def show(id)
    @dataset = Dataset.get(id)
    raise NotFound unless @dataset
    display @dataset
  end

  def new
    if params[:dataset_confirmed] && params[:dataset_confirmed] == "true"
      create(params[:dataset])
    else
      only_provides :html
      @dataset = nil
      @results = nil
      display @dataset
    end
  end

  def edit(id)
    only_provides :html
    @dataset = Dataset.get(id)
    raise NotFound unless @dataset
    display @dataset
  end

  def create(dataset)
    @dataset = Dataset.new(dataset)
    @curation = Curation.new(:single_dataset => true, :researcher_id => session.user.id, :created_at => Time.now, :updated_at => Time.now, :name => "Dataset_#{@dataset.id}_#{@dataset.scrape_type}_#{@dataset.params}")
    @curation.save!
    if @dataset.save!
      @curation.datasets << @dataset
      @curation.save!
      @dataset.save!
      redirect resource(@dataset), :message => {:notice => "Dataset was successfully created"}
    else
      message[:error] = "Dataset failed to be created"
      render :new
    end
  end

  def verify
    worker = WorkerDescription.first(:id => params[:worker_id])
    param_vals = Hash[params.select{|x,y|x.include?("param")}]
    parameters = Parameter.all(:id => param_vals.keys.collect{|x| x.gsub("param_", "")}).sort{|x,y| x.position<=>y.position}
    @results = Dataset.valid_params(worker.filename, parameters.collect{|param| param_vals["param_"+param.id.to_s]}.join(","))
    @dataset = Dataset.new(:scrape_type => worker.filename, :params => @results[:clean_params], :created_at => Time.now)
    render :new
  end
  
  def update(id, dataset)
    @dataset = Dataset.get(id)
    raise NotFound unless @dataset
    if @dataset.update(dataset)
       redirect resource(@dataset), :message => {:notice => "Dataset was successfully updated"}
    else
      message[:error] = "Dataset failed to be updated"
      display @dataset, :edit
    end
  end

  def destroy(id)
    @dataset = Dataset.get(id)
    raise NotFound unless @dataset
    if @dataset.destroy
      redirect resource(:dataset), :message => {:notice => "Dataset was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # Dataset
