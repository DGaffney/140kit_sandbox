class Ticket
  include DataMapper::Resource
  property :id, Serial
  property :title, String, :required => true
  property :text, Text
  property :severity, Integer
  property :created_at, ZonedTime
  belongs_to :researcher, Integer, :index => [:dataset_id]
end

