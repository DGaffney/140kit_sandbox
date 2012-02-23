class Coordinate
  include DataMapper::Resource
  property :id, Serial
  property :twitter_id, Integer, :min => 0, :max => 2**64-1, :unique_index => [:unique_coordinate]
  property :geo_id, String
  property :geo_type, String
  property :user_id, Integer, :min => 0, :max => 2**64-1
  property :lat, String, :unique_index => [:unique_coordinate]
  property :lon, String, :unique_index => [:unique_coordinate]
  property :dataset_id, String
  belongs_to :dataset, :unique_index => [:unique_coordinate], :index => [:dataset_coordinate], :child_key => :twitter_id
  belongs_to :tweet, :unique_index => [:unique_coordinate], :index => [:dataset_coordinate], :child_key => :twitter_id
end