class AnalysisMetadata
  include DataMapper::Resource
  property :id,   Serial
  property :function, String, :unique_index => [:unique_metadata]
  property :finished, Boolean
  property :rest, Boolean
  property :save_path, String
  belongs_to :curation, :unique_index => [:unique_metadata]
end