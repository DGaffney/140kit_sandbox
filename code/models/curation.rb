class Curation
  
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :index => [:curation_researcher_id]
  property :single_dataset, Boolean, :index => [:researcher_id_single_dataset], :default => true
  property :previously_imported, Boolean, :index => [:researcher_id_previously_imported], :default => false
  property :created_at, Time, :default => Time.now
  property :updated_at, Time, :default => Time.now
  property :archived, ParanoidBoolean, :default => false
  property :status, String, :default => "tsv_storing"
  property :researcher_id, Integer, :index => [:curation_researcher_id, :researcher_id, :researcher_id_previously_imported, :researcher_id_single_dataset]
  belongs_to :researcher, :child_key => :researcher_id
  has n, :datasets, :through => Resource
  has n, :analysis_metadatas
  has n, :graphs
  has n, :tweets, :through => :datasets
  has n, :users, :through => :datasets
  
  validates_presence_of :researcher_id, :name
  
  def stored_folder_name
    return name.downcase.gsub(/[\ |\=|\-|\(|\)|\*|\&|\^|\%|\$|\#|\@|\!|\,]/, "_")+"_"+id.to_s+"_"+researcher_id.to_s
  end
  
  def tweets_count
    return datasets.collect{|d| d.tweets_count}.sum
  end
  
  def entities_count
    return datasets.collect{|d| d.entities_count}.sum
  end

  def users_count
    return datasets.collect{|d| d.users_count}.sum
  end
  
  def analysis_metadatas
    AnalysisMetadata.all(:curation_id => self.id)
  end
  
  def analysis_metadatas_scoped(analytical_offering)
    self.analysis_metadatas.select{|analysis_metadata| analysis_metadata.function == analytical_offering.function}
  end
  
  def full_delete(include_datasets=false)
    AnalysisMetadata.all(:curation_id => self.id).each do |analysis_metadata|
      AnalyticalOfferingVariable.all(:analysis_metadata_id => analysis_metadata.id).destroy
      Lock.all(:classname => "AnalysisMetadata", :with_id => analysis_metadata.id).destroy
      analysis_metadata.destroy
    end
    Graph.all(:curation_id => self.id).each do |graph|
      Lock.all(:classname => "Graph", :with_id => graph.id).destroy
      graph.destroy
    end
    GraphPoint.all(:curation_id => self.id).destroy
    Edge.all(:curation_id => self.id).destroy
    JaccardCoefficient.all(:curation_id => self.id).destroy
    mail = Mail.new
    mail.recipient = self.researcher.email
    mail.researcher_id = self.researcher.id
    mail.subject = "Curation #{self.name} (id: #{self.id}) successfully removed from system."
    mail.message_content = "Hello, #{self.researcher.user_name}, this is a friendly reminder that, as per your request, all data associated with the #{self.name} curation has now been successfully removed from our system."
    if include_datasets
      self.datasets.each do |dataset|
        dataset.full_delete
      end
    end
    Lock.all(:classname => "Curation", :with_id => self.id).destroy
    self.destroy
  end
  
  def still_collecting?
    still_collecting = false
    self.datasets.each do |dataset|
      still_collecting = true if !dataset.scrape_finished
    end
    return still_collecting
  end
  
  def all_analysis_metadatas_clear?
    all_free = self.analysis_metadatas.empty? || !self.analysis_metadatas.collect{|am| !am.owned?}.include?(true)
    all_finished = self.analysis_metadatas.empty? || !self.analysis_metadatas.collect{|am| !am.finished}.include?(true)
    return all_free && all_finished
  end
end
