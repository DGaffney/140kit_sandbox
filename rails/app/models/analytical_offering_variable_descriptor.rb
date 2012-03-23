class AnalyticalOfferingVariableDescriptor < ActiveRecord::Base
  belongs_to :analytical_offering
  
  def default_value(params)
    return params["aovd"] && params["aovd"][self.name] || ""
  end
  
  def step
    return values.split(",").last.to_f/100
  end
  
  def range
    return values.split(",").first.to_f..values.split(",").last.to_f
  end
end
