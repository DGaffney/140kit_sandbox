class AnalyticalOffering
  include DataMapper::Resource
  property :id, Serial
  property :title, String, :index => [:unique_metadata]
  property :description, Text, :index => [:unique_metadata]
  property :function, String, :index => [:unique_analytical_offering]
  property :rest, Boolean, :index => [:unique_metadata]
  property :source_code_link, String, :index => [:unique_metadata]
  property :created_by, String, :index => [:unique_metadata]
  property :created_by_link, String, :index => [:unique_metadata]
  property :enabled, Boolean, :index => [:unique_metadata]
  property :save_path, String, :index => [:unique_metadata]
  property :language, String, :index => [:unique_analytical_offering]
  property :access_level, String, :index => [:unique_metadata]
end