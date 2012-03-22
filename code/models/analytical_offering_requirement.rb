class AnalyticalOfferingRequirement

  include DataMapper::Resource
  property :id, Serial
  property :position, Integer, :default => 0
  property :analytical_offering_requirement_id, Integer
  property :analytical_offering_id, Integer
  belongs_to :analytical_offering

  def requirement
    return AnalyticalOffering.first(:id => self.analytical_offering_requirement_id)
  end
end