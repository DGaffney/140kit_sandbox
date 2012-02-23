class Entity
  include DataMapper::Resource
  property :id, Serial
  property :dataset_id, Integer, :index => [:dataset_id, :dataset_id_twitter_id, :dataset_id_name, :dataset_id_value]
  property :twitter_id, Integer, :unique_index => [:unique_entity], :index => [:twitter_id, :dataset_id_twitter_id, :twitter_id_name, :twitter_id_value, :twitter_id_name_value], :min => 0, :max => 2**64-1
  # property :kind, String, :unique_index => [:unique_entity], :index => [:kind, :dataset_id_kind, :twitter_id_kind, :kind_name, :kind_value, :dataset_id_twitter_id_kind, :dataset_id_kind_name, :dataset_id_kind_value, :twitter_id_kind_name, :twitter_id_kind_value, :twitter_id_kind_name_value, :dataset_id_kind_name_value, :dataset_id_twitter_id_kind_name, :dataset_id_twitter_id_kind_value, :dataset_id_twitter_id_kind_name_value]
  property :name, String, :unique_index => [:unique_entity], :index => [:name, :dataset_id_name, :twitter_id_name, :name_value, :twitter_id_name_value]
  property :value, Text, :unique_index => [:unique_entity], :index => [:value, :dataset_id_value, :twitter_id_value, :name_value, :twitter_id_name_value]
  belongs_to :tweet, :parent_key => :twitter_id, :child_key => :twitter_id
  belongs_to :dataset, :child_key => :dataset_id
  
  def curations
    self.dataset.curations-[self.curation]
  end
  
  def curation
    self.dataset.curations.first(:single_dataset => true)
  end
  
  def user
    self.tweet.user
  end
end