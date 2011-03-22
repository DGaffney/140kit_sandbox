class Curation < Model
  
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :index => [:curation_researcher_id]
  property :single_dataset, Boolean, :index => [:researcher_id_single_dataset], :default => true
  property :analyzed, Boolean, :index => [:researcher_id_analyzed], :default => false
  property :created_at, Time, :default => Time.now
  property :updated_at, Time, :default => Time.now
  belongs_to :researcher, :index => [:curation_researcher_id, :researcher_id, :researcher_id_analyzed, :researcher_id_single_dataset]
  has n, :datasets, :through => Resource
  has n, :analysis_metadatas
  
  def stored_folder_name
    return name.downcase.gsub(/[\ |\=|\-|\(|\)|\*|\&|\^|\%|\$|\#|\@|\!]/, "_")+"_"+id.to_s+"_"+researcher_id.to_s
  end
end