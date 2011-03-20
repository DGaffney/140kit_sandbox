class User < Model
  include DataMapper::Resource
  property :id, Serial
  property :twitter_id, Integer, :index => [:twitter_id_dataset, :twitter_id], :unique_index => [:unique_user], :min => 0, :max => 2**64-1
  property :name, String, :index => [:name]
  property :screen_name, String, :index => [:screen_name]
  property :location, Text, :index => [:location_dataset, :location]
  property :description, String, :index => [:description]
  property :profile_image_url, String, :index => [:profile_image_url]
  property :url, Text, :index => [:url_dataset, :url]
  property :protected, Boolean, :index => [:protected_dataset, :protected]
  property :followers_count, Integer, :index => [:followers_count_dataset, :followers_count]
  property :profile_background_color, String, :index => [:profile_background_color_dataset, :profile_background_color]
  property :profile_text_color, String, :index => [:profile_text_color_dataset, :profile_text_color]
  property :profile_link_color, String, :index => [:profile_link_color_dataset, :profile_link_color]
  property :profile_sidebar_fill_color, String, :index => [:profile_sidebar_fill_color_dataset, :profile_sidebar_fill_color]
  property :profile_sidebar_border_color, String, :index => [:profile_sidebar_border_color_dataset, :profile_sidebar_border_color]
  property :friends_count, Integer, :index => [:friends_count_dataset, :friends_count]
  property :created_at, Time, :index => [:created_at_dataset, :created_at]
  property :favourites_count, Integer, :index => [:favorites_count_dataset, :favorites_count]
  property :utc_offset, Integer, :index => [:utc_offset_dataset, :utc_offset]
  property :time_zone, String, :index => [:time_zone_dataset, :time_zone]
  property :profile_background_image_url, String, :index => [:profile_background_image_url]
  property :profile_background_tile, Boolean, :index => [:profile_background_tile_dataset, :profile_background_tile], :default => false
  property :profile_use_background_image, Boolean, :index => [:profile_use_background_image_dataset, :profile_use_background_image], :default => false
  property :show_all_inline_media, Boolean, :index => [:show_all_inline_media_dataset, :show_all_inline_media], :default => false
  property :is_translator, Boolean, :index => [:is_translator_dataset, :is_translator], :default => false
  property :notifications, Boolean, :index => [:notifications_dataset, :notifications], :default => false
  property :geo_enabled, Boolean, :index => [:geo_enabled_dataset, :geo_enabled], :default => false
  property :verified, Boolean, :index => [:verified_dataset, :verified], :default => false
  property :following, Boolean, :index => [:following_dataset, :following], :default => false
  property :statuses_count, Integer, :index => [:statuses_count_dataset, :statuses_count]
  property :contributors_enabled, Boolean, :index => [:contributors_enabled_dataset, :contributors_enabled], :default => false
  property :lang, String, :index => [:lang_dataset, :lang]
  property :listed_count, Integer, :index => [:listed_count_dataset, :listed_count]
  property :follow_request_sent, Boolean, :index => [:follow_request_sent_dataset, :follow_request_sent], :default => false
  belongs_to :dataset, Integer, :unique_index => [:unique_user], :index => [:location_dataset, :url_dataset, :protected_dataset, :followers_count_dataset, :profile_background_color_dataset, :profile_text_color_dataset, :profile_link_color_dataset, :profile_sidebar_fill_color_dataset, :profile_sidebar_border_color_dataset, :friends_count_dataset, :created_at_dataset, :favorites_count_dataset, :utc_offset_dataset, :time_zone_dataset, :profile_background_tile_dataset, :profile_use_background_image_dataset, :show_all_inline_media_dataset, :is_translator_dataset, :notifications_dataset, :geo_enabled_dataset, :verified_dataset, :following_dataset, :statuses_count_dataset, :contributors_enabled_dataset, :lang_dataset, :listed_count_dataset, :follow_request_sent_dataset]
end