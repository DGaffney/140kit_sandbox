class TrendingTopic
  include DataMapper::Resource
  property :id,   Serial
  property :woeid, Integer
  property :created_at, ZonedTime
  property :ended_at, ZonedTime
  property :name, String
  property :dataset_id, Integer
end