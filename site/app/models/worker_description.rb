class WorkerDescription
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :filename, String
  property :description, Text
  property :type, String
  property :active, Boolean
  has n, :parameters
end