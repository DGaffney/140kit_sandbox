class Post
  include DataMapper::Resource
  property :id, Serial
  property :title, String, :required => true
  property :slug, String
  property :text, Text
  property :created_at, ZonedTime
  property :status, String
  belongs_to :researcher, Integer, :index => [:dataset_id]
end

