class AnalyticalOfferingVariable < ActiveRecord::Base
  belongs_to :analysis_metadata
  belongs_to :analytical_offering_variable_descriptor
  
  def function
    return analytical_offering_variable_descriptor.analytical_offering.function
  end
  
  def name
    return analytical_offering_variable_descriptor.name
  end
  
  def kind
    return analytical_offering_variable_descriptor.kind
  end

  def description
    return analytical_offering_variable_descriptor.description
  end
  
  def position
    return analytical_offering_variable_descriptor.position
  end
end
