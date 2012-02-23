class JaccardCoefficient
  include DataMapper::Resource
  property :id, Serial
  property :curation_id, Integer
  property :social_flow_tweet_twitter_id, Integer, :unique_index => [:unique_coefficient], :min => 0, :max => 2**64-1, :required => true
  property :referencing_tweet_twitter_id, Integer, :unique_index => [:unique_coefficient], :min => 0, :max => 2**64-1, :required => true
  property :within_percentile, Boolean
  property :analysis_metadata_id, Integer
  property :coefficient, Float, :unique_index => [:unique_coefficient]
  belongs_to :curation, :unique_index => [:unique_coefficient], :index => [:curation_id], :required => true
  belongs_to :analysis_metadata, :unique_index => [:unique_coefficient], :required => true
end