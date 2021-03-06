class Graph < ActiveRecord::Base
  belongs_to :curation
  belongs_to :analysis_metadata
  has_many :graph_points
  has_many :edges
  def pretty_title
    return self.title.split("|").collect{|part| part.split("_").collect{|w| w.capitalize}.join(" ")}.join(" / ")
  end
end
