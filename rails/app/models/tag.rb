class Tag < ActiveRecord::Base
  has_and_belongs_to_many :curations, :join_table => "curation_tags"
  has_and_belongs_to_many :posts, :join_table => "post_tags"
  validates_uniqueness_of :value
  validates_length_of :value, :in => 2..255, :allow_nil => false, :allow_blank => false
end
