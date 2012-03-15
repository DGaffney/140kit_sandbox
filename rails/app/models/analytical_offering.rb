class AnalyticalOffering < ActiveRecord::Base
  has_many :analysis_metadatas
  has_many :analytical_offering_variable_descriptors
  has_many :analytical_offering_variables
end
