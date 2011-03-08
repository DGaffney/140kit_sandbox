class Dataset
  include DataMapper::Resource
  property :id, Serial
  property :scrape_type, String, :index => [:scrape_type, :scrape_method_scrape_type]
  property :start_time, DateTime
  property :length, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
  property :scrape_finished, Boolean
  property :scrape_method, String, :index => [:scrape_method, :scrape_method_scrape_type]
  property :instance_id, String, :index => [:instance_id]
  property :params, String
  property :tweets_count, Integer
  property :users_count, Integer
  has n, :curations, :through => Resource
end