class AnalyticalOfferingVariable
  include DataMapper::Resource
  property :id, Serial, :serial => true
  property :position, Integer, :unique_index => [:unique_analytical_offering_variable]
  property :value, String, :unique_index => [:unique_analytical_offering_variable]
  property :kind, String, :unique_index => [:unique_analytical_offering_variable]
  belongs_to :analysis_metadata, :unique_index => [:unique_analytical_offering_variable]
end