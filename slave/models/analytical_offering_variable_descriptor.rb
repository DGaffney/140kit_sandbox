class AnalyticalOfferingVariableDescriptor
  include DataMapper::Resource
  property :id, Serial, :serial => true
  property :name, String
  property :description, Text
  property :user_modifiable, Boolean
  property :position, Integer, :unique_index => [:unique_analytical_offering_variable_descriptor]
  property :kind, String, :unique_index => [:unique_analytical_offering_variable_descriptor]
  property :analytical_offering_id, Integer, :unique_index => [:unique_analytical_offering_variable_descriptor]
  belongs_to :analytical_offering, :child_key => :analytical_offering_id
end