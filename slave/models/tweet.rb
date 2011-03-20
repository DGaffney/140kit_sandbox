class Tweet < Model
  include DataMapper::Resource
  property :id,           Serial
  property :twitter_id,   Integer, :index => [:twitter_id_dataset, :twitter_id], :unique_index => [:unique_tweet], :min => 0, :max => 2**64-1
  property :user_id,      Integer, :index => [:user_id_dataset, :user_id], :min => 0, :max => 2**64-1
  property :text,         Text, :index => [:text_dataset, :text]
  property :language,     String, :index => [:language_dataset, :language]
  property :screen_name,  String, :index => [:screen_name_dataset, :screen_name]
  property :location,     Text, :index => [:location_dataset, :location]
  property :in_reply_to_status_id, Integer, :index => [:in_reply_to_status_id_dataset, :in_reply_to_status_id]
  property :in_reply_to_user_id,   Integer, :index => [:in_reply_to_user_id_dataset, :in_reply_to_user_id]
  property :truncated,    Boolean, :index => [:truncated_dataset, :truncated], :default => false
  property :in_reply_to_screen_name, String, :index => [:retweet_id_dataset, :retweet_id]
  property :created_at,   Time, :index => [:created_at_dataset, :created_at]
  property :retweet_count,  Integer, :index => [:retweet_count_dataset, :retweet_count]
  property :lat,          String, :index => [:lat_dataset, :lat]
  property :lon,          String, :index => [:lon_dataset, :lon]
  property :source,       Text, :index => [:source_dataset, :source]
  property :retweeted,  Boolean, :index => [:retweeted_dataset, :retweeted], :default => false
  belongs_to :user, :index => [:user_id_dataset, :user_id], :child_key => :user_id
  belongs_to :dataset, :unique_index => [:unique_tweet], :index => [:dataset_id, :twitter_id_dataset, :text_dataset, :language_dataset, :user_id_dataset, :screen_name_dataset, :location_dataset, :in_reply_to_status_id_dataset, :in_reply_to_user_id_dataset, :truncated_dataset, :retweet_id_dataset, :created_at_dataset, :retweet_count_dataset, :lat_dataset, :lon_dataset, :retweeted_dataset, :source_dataset, :user_id_dataset]
  
  #hack; this should actually be something like:
  #has n :entities, :through => :entity, :parent_key => :twitter_id, :child_key => :twitter_id
  #but it wasn't working, so i said fuck it for now. FIFN
  def entities
    return Entity.all(:twitter_id => twitter_id)
  end
end