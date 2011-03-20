class AnalyticalOfferingVariable < Model
  include DataMapper::Resource
  property :id, Serial, :serial => true
  property :value, Object
  property :analysis_metadata_id, Integer, :unique_index => [:unique_analytical_offering_variable]
  property :analytical_offering_variable_descriptor_id, Integer, :unique_index => [:unique_analytical_offering_variable]
  belongs_to :analysis_metadata, :child_key => :analysis_metadata_id
  belongs_to :analytical_offering_variable_descriptor, :child_key => :analytical_offering_variable_descriptor_id

  def function
    return analytical_offering_variable_descriptor.analytical_offering.function
  end
  
  def name
    return analytical_offering_variable_descriptor.name
  end
  
  def kind
    return analytical_offering_variable_descriptor.kind
  end
  
  def position
    return analytical_offering_variable_descriptor.position
  end
  
end