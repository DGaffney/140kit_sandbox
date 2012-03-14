class Curation < ActiveRecord::Base
  belongs_to :researcher
  has_many :datasets
end
