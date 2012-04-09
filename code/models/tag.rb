class Tag
  include DataMapper::Resource
  property :id, Serial
  property :value, String, :length => 40
  has n, :curations, :through => Resource
  has n, :posts, :through => Resource
end