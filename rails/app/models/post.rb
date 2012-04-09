class Post < ActiveRecord::Base
  belongs_to :researcher
  has_and_belongs_to_many :tags, :join_table => "post_tags"

  def self.latest_featured
    Post.where(:status => "featured").limit(1).order("created_at ASC").first
  end
  
  def teaser(length=250)
    words = self.text.gsub(/<.*>/, "")[0..length].split(" ")
    words[0..words.length-2].join(" ")+"..."
  end
end
