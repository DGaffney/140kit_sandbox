class Geo
  include DataMapper::Resource
  property :id, Serial
  property :twitter_id, Integer, :min => 0, :max => 2**64-1, :unique_index => [:unique_geo]
  property :geo_id, String, :unique_index => [:unique_geo]
  property :user_id, Integer, :min => 0, :max => 2**64-1
  property :screen_name, String
  property :geo_type, String
  property :country, String
  property :country_code, String
  property :full_name, String
  property :name, String
  property :street_address, String
  property :locality, String
  property :region, String
  property :iso3, String
  property :postal_code, String
  property :phone, String
  property :url, String
  property :app_id, String
  property :dataset_id, String
  belongs_to :dataset, :unique_index => [:unique_geo], :index => [:dataset_geo]
  belongs_to :tweet, :unique_index => [:unique_geo], :index => [:dataset_geo]
end