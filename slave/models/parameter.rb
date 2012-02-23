class Parameter
  include DataMapper::Resource
  property :id, Serial
  property :worker_description_id, Integer
  property :name, String
  property :position, Integer
  property :description, Text
  property :active, Boolean
  belongs_to :worker_description, :child_key => :worker_description_id
end