class Researcher < ActiveRecord::Base

  has_many :curations
  has_many :posts

  validates :name, :user_name, presence: true
  validates :uid, :oauth_token, :oauth_token_secret, presence: true, uniqueness: true,  on: :create
  validates :user_name, uniqueness: true
  validates :email, uniqueness: true, email: true, presence: true, on: :update
  # validates :website_url, :affiliation_url, format: { with: URI::regexp(%w(http https)), message: "Invalid URL! Try adding 'http://'" }

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.oauth_token = auth["credentials"]["token"]
      user.oauth_token_secret = auth["credentials"]["secret"]
      user.user_name = auth.extra.raw_info.screen_name
      user.name = auth.extra.raw_info.name
      user.location = auth.extra.raw_info.location
      user.website_url = auth.extra.raw_info.url
      user.info = auth.extra.raw_info.description
      user.affiliation_url = "http://140kit.com"
      user.role = Researcher.count == 0 ? "Admin" : "User"
      user.join_date = Time.now
      user.first_time = true
    end
  end

  def twitter_url
    "http://twitter.com/#{self.user_name}"
  end

  def twitter_pic(size)
    # :bigger, :normal, :mini, :original
    "https://api.twitter.com/1/users/profile_image?screen_name=#{self.user_name}&size=#{size.to_s}"
  end

  def to_param
    self.user_name
  end
  
  def human_join_date
    return self.join_date.strftime("%b %d, %Y")
  end
  
  def self.roles
    return Setting.find_by_name("roles").value
  end
  
  def admin?
    return Researcher.find(self.id).role == "Admin"
  end
  
  def curations_count
    return curations.count
  end
  
  def safe_website_url
    if self.website_url[0..6] != "http://"
      "http://"+self.website_url
    else 
      return self.website_url
    end
  end
  
  def self.highest_role
    return Setting.find_by_name("roles").actual_value[-2]
  end
  
  def self.roles
    return Setting.find_by_name("roles").actual_value
  end
end
