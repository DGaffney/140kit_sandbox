class Graph < ActiveRecord::Base
  belongs_to :curation
  belongs_to :analysis_metadata
  has_many :graph_points
  def pretty_title
    return self.title.split("_").collect{|w| w.capitalize}.join(" ")
  end
end
