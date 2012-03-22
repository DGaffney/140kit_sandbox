class AnalyticalOfferingRequirement < ActiveRecord::Base
  belongs_to :analytical_offering
  
  def requirement
    return AnalyticalOffering.find(analytical_offering_requirement_id)
  end
end
