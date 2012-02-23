class Friendship
  include DataMapper::Resource
  property :id, Serial
  property :followed_user_name, String, :unique_index => [:unique_edge], :index => [:followed_user_name]
  property :follower_user_name, String, :unique_index => [:unique_edge], :index => [:follower_user_name]
  property :followed_user_id, Integer, :unique_index => [:unique_edge], :index => [:followed_user], :min => 0, :max => 2**64-1
  property :follower_user_id, Integer, :unique_index => [:unique_edge], :index => [:follower_user], :min => 0, :max => 2**64-1
  property :created_at, Time, :unique_index => [:unique_edge], :index => [:created_at]
  property :deleted_at, Time, :unique_index => [:unique_edge], :index => [:deleted_at]
  belongs_to :dataset, :unique_index => [:unique_edge], :index => [:dataset_edge]
end