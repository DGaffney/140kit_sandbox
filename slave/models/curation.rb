class Curation
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :unique_index => [:unique_curation]
  property :single_dataset, Boolean, :index => [:researcher_id_single_dataset], :default => true
  property :analyzed, Boolean, :index => [:researcher_id_analyzed], :default => false
  property :created_at, Time
  property :updated_at, Time
  belongs_to :researcher, :unique_index => [:unique_curation], :index => [:researcher_id, :researcher_id_analyzed, :researcher_id_single_dataset]
  has n, :datasets, :through => Resource
  has n, :analysis_metadatas
  
  def folder_name
    return name.downcase.gsub(/[\ |\=|\-|\(|\)|\*|\&|\^|\%|\$|\#|\@|\!]/, "_")
  end
end