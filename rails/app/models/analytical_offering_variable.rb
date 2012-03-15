class AnalyticalOfferingVariable < ActiveRecord::Base
  belongs_to :analysis_metadata
  belongs_to :analytical_offering_variable_descriptor
end
