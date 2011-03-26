class Lock
  include DataMapper::Resource
  property :id, Serial
  property :classname, String, :index => [:unique_metadata]
  property :with_id, Integer, :index => [:unique_metadata]
  property :instance_id, String, :length => 40
  validates_uniqueness_of :with_id, :scope => :classname
end