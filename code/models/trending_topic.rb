class TrendingTopic
  include DataMapper::Resource
  property :id,   Serial
  property :woeid, Integer
  property :created_at, Time
  property :ended_at, Time
  property :name, String
  property :dataset_id, Integer
end