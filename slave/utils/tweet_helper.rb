# ### THIS IS A TWEET ###
# 
# {
#   "coordinates"=>nil, "created_at"=>"Fri Jan 14 05:57:29 +0000 2011", "favorited"=>false, "truncated"=>false, "id_str"=>"25793604714762241", 
#   "in_reply_to_user_id_str"=>nil, "contributors"=>nil, "text"=>"setelah td telfonan, skrg musti ngejelasin shallot lg di sms &gt;&lt;\" lol dri td kmna aja pas d'tlp wkwkw", 
#   "id"=>25793604714762241, "retweet_count"=>0, "in_reply_to_status_id_str"=>nil, "geo"=>nil, "retweeted"=>false, "in_reply_to_user_id"=>nil, 
#   "in_reply_to_status_id"=>nil, "in_reply_to_screen_name"=>nil, "source"=>"web", 
#   
#   
#   "entities"=>{"urls"=>[], "hashtags"=>[], "user_mentions"=>[]},
#   
#   
#   "place"=>{"name"=>"Kelapa Gading", "country_code"=>"", "country"=>"Indonesia", "attributes"=>{}, "url"=>"http://api.twitter.com/1/geo/id/c23a5ae63324c567.json", 
#     "id"=>"c23a5ae63324c567", "bounding_box"=>{"coordinates"=>[[[106.886777, -6.181952], [106.934269, -6.181952], [106.934269, -6.136277], [106.886777, -6.136277]]], "type"=>"Polygon"}, 
#     "full_name"=>"Kelapa Gading, Jakarta Utara", "place_type"=>"city"}, 
#     
#   
  # "user"=>{"profile_background_tile"=>true, "name"=>"Glorya Vitantri", "profile_sidebar_fill_color"=>"f9fcfc", "profile_sidebar_border_color"=>"0ed2f5", 
  #   "location"=>"UT: -6.893552,107.613068", "profile_image_url"=>"http://a0.twimg.com/profile_images/1208894739/DSC00260_normal.JPG", "created_at"=>"Fri Aug 14 05:57:40 +0000 2009", 
  #   "is_translator"=>false, "follow_request_sent"=>nil, "id_str"=>"65575036", "profile_link_color"=>"0dc8f7", "favourites_count"=>12, "contributors_enabled"=>false, 
  #   "url"=>"http://twitter.com/Actorkimbeom", "utc_offset"=>25200, "id"=>65575036, "listed_count"=>28, "profile_use_background_image"=>true, "protected"=>false, 
  #   "profile_text_color"=>"5e676b", "lang"=>"en", "followers_count"=>337, "time_zone"=>"Jakarta", "geo_enabled"=>true, 
  #   "description"=>"im spontanius,,cheerfull,,smart,,\r\nfriendly,,and just wants to make more friends.^^ follow me na.", "verified"=>false, 
  #   "profile_background_color"=>"f5f5f5", "notifications"=>nil, "friends_count"=>149, "profile_background_image_url"=>"http://a0.twimg.com/profile_background_images/145583558/1.jpg", 
  #   "statuses_count"=>13835, "screen_name"=>"Rhylze", "following"=>nil, "show_all_inline_media"=>true}
# }
# 
# ######

class TweetHelper
  
  @@allowed_tweet_fields = Tweet.properties.collect {|p| p.name }
  @@allowed_user_fields = User.properties.collect {|p| p.name }
  
  def self.prepped_tweet_and_user(json)
    tweet = self.prep_tweet(json)
    user = self.prep_user(json[:user])
    return tweet, user
  end
  
  def self.prep_tweet(json)
    tweet = {}
    json.each do |k,v|
      case k.to_sym
      when :id
        tweet[:twitter_id] = v
      when :user
        tweet[:user_id] = v[:id]
        tweet[:screen_name] = v[:screen_name]
        tweet[:language] = v[:lang]
        tweet[:location] = v[:location]
      when :place
        tweet[:location] = v[:full_name] if !v.nil?
      when :created_at
        tweet[:created_at] = DateTime.parse(v)
      else
        tweet[k.to_sym] = v if @@allowed_tweet_fields.include?(k.to_sym)
      end
      tweet[:user_id] = json[:user][:id]
      tweet[:lat], tweet[:lon] = self.derive_lat_lon(json)
      tweet[:in_reply_to_status_id], tweet[:in_reply_to_user_id], tweet[:in_reply_to_screen_name] = self.derive_retweet_status(json)
    end
    return tweet
  end
  
  def self.derive_lat_lon(json)
    lat = nil
    lon = nil
    lat = json[:geo]&&json[:geo][:coordinates]&&json[:geo][:coordinates].class==Array&&json[:geo][:coordinates].length==2&&json[:geo][:coordinates].first ||
    json[:place]&&json[:place][:bounding_box]&&json[:place][:bounding_box][:coordinates]&&json[:place][:bounding_box][:coordinates].centroid.first ||
    json[:coordinates]&&json[:coordinates][:coordinates].first ||
    nil
    lon = json[:geo]&&json[:geo][:coordinates]&&json[:geo][:coordinates].class==Array&&json[:geo][:coordinates].length==2&&json[:geo][:coordinates].last ||
    json[:place]&&json[:place][:bounding_box]&&json[:place][:bounding_box][:coordinates]&&json[:place][:bounding_box][:coordinates].centroid.last ||
    json[:coordinates]&&json[:coordinates][:coordinates].last ||
    nil
    return lat, lon
  end
  
  def self.derive_retweet_status(json)
    in_reply_to_status_id = nil
    in_reply_to_status_id = json[:in_reply_to_status_id] ||
    json[:retweeted_status]&&json[:retweeted_status][:id]
    in_reply_to_user_id = nil
    in_reply_to_user_id = json[:in_reply_to_user_id] ||
    json[:retweeted_status]&&json[:retweeted_status][:user]&&json[:retweeted_status][:user][:id]
    in_reply_to_screen_name = nil
    in_reply_to_screen_name = json[:in_reply_to_screen_name] ||
    json[:retweeted_status]&&json[:retweeted_status][:user]&&json[:retweeted_status][:user][:screen_name]
    return in_reply_to_status_id, in_reply_to_user_id, in_reply_to_screen_name
  end
  
  def self.prep_user(json)
    user = {}
    json.each do |k,v|
      case k.to_sym
      when :id
        user[:twitter_id] = v
      when :created_at
        user[:created_at] = Time.parse(v)
      else
        user[k.to_sym] = v if @@allowed_user_fields.include?(k.to_sym)
      end
    end
    return user
  end
  
end