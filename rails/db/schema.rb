# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 0) do

  create_table "analysis_metadatum", :force => true do |t|
    t.boolean "finished",               :default => false
    t.boolean "rest",                   :default => false
    t.integer "curation_id"
    t.integer "analytical_offering_id"
  end

  create_table "analytical_offering_variable_descriptors", :force => true do |t|
    t.string  "name",                   :limit => 50
    t.text    "description"
    t.boolean "user_modifiable"
    t.integer "position"
    t.string  "kind",                   :limit => 50
    t.integer "analytical_offering_id"
  end

  add_index "analytical_offering_variable_descriptors", ["position", "kind", "analytical_offering_id"], :name => "unique_analytical_offering_variable_descriptors_unique_analytica", :unique => true

  create_table "analytical_offering_variables", :force => true do |t|
    t.text    "value"
    t.integer "analysis_metadata_id"
    t.integer "analytical_offering_variable_descriptor_id"
  end

  add_index "analytical_offering_variables", ["analysis_metadata_id", "analytical_offering_variable_descriptor_id"], :name => "unique_analytical_offering_variables_unique_analytical_offering_", :unique => true

  create_table "analytical_offerings", :force => true do |t|
    t.string  "title",            :limit => 50
    t.text    "description"
    t.string  "function",         :limit => 50
    t.boolean "rest",                           :default => false
    t.string  "created_by",       :limit => 50
    t.string  "created_by_link",  :limit => 50
    t.boolean "enabled",                        :default => true
    t.string  "language",         :limit => 50
    t.string  "access_level",     :limit => 50
    t.text    "source_code_link"
  end

  add_index "analytical_offerings", ["function", "language"], :name => "index_analytical_offerings_unique_analytical_offering"

  create_table "auth_users", :force => true do |t|
    t.string "screen_name", :limit => 50
    t.string "password",    :limit => 50
    t.string "instance_id", :limit => 40
  end

  add_index "auth_users", ["screen_name", "password"], :name => "unique_auth_users_unique_auth_user", :unique => true

  create_table "coordinates", :force => true do |t|
    t.integer "twitter_id", :limit => 8
    t.string  "geo_id",     :limit => 50
    t.string  "geo_type",   :limit => 50
    t.integer "user_id",    :limit => 8
    t.string  "lat",        :limit => 50
    t.string  "lon",        :limit => 50
    t.string  "dataset_id", :limit => 50
  end

  add_index "coordinates", ["twitter_id", "lat", "lon"], :name => "unique_coordinates_unique_coordinate", :unique => true

  create_table "curation_datasets", :id => false, :force => true do |t|
    t.integer "curation_id", :null => false
    t.integer "dataset_id",  :null => false
  end

  create_table "curations", :force => true do |t|
    t.string   "name",           :limit => 50
    t.boolean  "single_dataset",               :default => true
    t.boolean  "analyzed",                     :default => false
    t.datetime "created_at",                   :default => '2012-01-26 22:28:17'
    t.datetime "updated_at",                   :default => '2012-01-26 22:28:17'
    t.boolean  "archived",                     :default => false
    t.integer  "researcher_id"
  end

  add_index "curations", ["analyzed", "researcher_id"], :name => "index_curations_researcher_id_analyzed"
  add_index "curations", ["name", "researcher_id"], :name => "index_curations_curation_researcher_id"
  add_index "curations", ["researcher_id"], :name => "index_curations_researcher_id"
  add_index "curations", ["single_dataset", "researcher_id"], :name => "index_curations_researcher_id_single_dataset"

  create_table "datasets", :force => true do |t|
    t.string   "scrape_type",     :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "scrape_finished",               :default => false
    t.string   "instance_id",     :limit => 50
    t.string   "params",          :limit => 50
    t.integer  "tweets_count",                  :default => 0
    t.integer  "users_count",                   :default => 0
    t.integer  "entities_count",                :default => 0
  end

  add_index "datasets", ["instance_id"], :name => "index_datasets_instance_id"
  add_index "datasets", ["scrape_type"], :name => "index_datasets_scrape_type"

  create_table "edges", :force => true do |t|
    t.string   "start_node",           :limit => 50
    t.string   "end_node",             :limit => 50
    t.datetime "time"
    t.string   "edge_id",              :limit => 50
    t.boolean  "flagged",                            :default => false
    t.string   "style",                :limit => 50
    t.integer  "analysis_metadata_id",                                  :null => false
    t.integer  "graph_id",                                              :null => false
    t.integer  "curation_id",                                           :null => false
  end

  add_index "edges", ["analysis_metadata_id"], :name => "index_edges_analysis_metadata"
  add_index "edges", ["curation_id"], :name => "index_edges_curation"
  add_index "edges", ["edge_id"], :name => "index_edges_edge_id"
  add_index "edges", ["edge_id"], :name => "index_edges_edge_id_edge"
  add_index "edges", ["end_node"], :name => "index_edges_end_node"
  add_index "edges", ["end_node"], :name => "index_edges_end_node_edge"
  add_index "edges", ["graph_id"], :name => "index_edges_graph"
  add_index "edges", ["start_node", "end_node", "time", "edge_id"], :name => "unique_edges_unique_edge", :unique => true
  add_index "edges", ["start_node"], :name => "index_edges_start_node"
  add_index "edges", ["start_node"], :name => "index_edges_start_node_edge"
  add_index "edges", ["time"], :name => "index_edges_time"
  add_index "edges", ["time"], :name => "index_edges_time_edge"

  create_table "entities", :force => true do |t|
    t.integer "dataset_id"
    t.integer "twitter_id", :limit => 8
    t.string  "name",       :limit => 50
    t.text    "value"
  end

  add_index "entities", ["dataset_id", "name"], :name => "index_entities_dataset_id_name"
  add_index "entities", ["dataset_id", "twitter_id"], :name => "index_entities_dataset_id_twitter_id"
  add_index "entities", ["dataset_id"], :name => "index_entities_dataset_id"
  add_index "entities", ["name"], :name => "index_entities_name"
  add_index "entities", ["twitter_id", "name"], :name => "index_entities_twitter_id_name"
  add_index "entities", ["twitter_id"], :name => "index_entities_twitter_id"

  create_table "friendships", :force => true do |t|
    t.string   "followed_user_name", :limit => 50
    t.string   "follower_user_name", :limit => 50
    t.integer  "followed_user_id",   :limit => 8
    t.integer  "follower_user_id",   :limit => 8
    t.datetime "created_at"
    t.datetime "deleted_at"
    t.integer  "dataset_id",                       :null => false
  end

  add_index "friendships", ["created_at"], :name => "index_friendships_created_at"
  add_index "friendships", ["dataset_id"], :name => "index_friendships_dataset"
  add_index "friendships", ["deleted_at"], :name => "index_friendships_deleted_at"
  add_index "friendships", ["followed_user_id"], :name => "index_friendships_followed_user"
  add_index "friendships", ["followed_user_name", "follower_user_name", "followed_user_id", "follower_user_id", "created_at", "deleted_at"], :name => "unique_friendships_unique_edge", :unique => true
  add_index "friendships", ["followed_user_name"], :name => "index_friendships_followed_user_name"
  add_index "friendships", ["follower_user_id"], :name => "index_friendships_follower_user"
  add_index "friendships", ["follower_user_name"], :name => "index_friendships_follower_user_name"

  create_table "geos", :force => true do |t|
    t.integer "twitter_id",     :limit => 8
    t.string  "geo_id",         :limit => 50
    t.integer "user_id",        :limit => 8
    t.string  "screen_name",    :limit => 50
    t.string  "geo_type",       :limit => 50
    t.string  "country",        :limit => 50
    t.string  "country_code",   :limit => 50
    t.string  "full_name",      :limit => 50
    t.string  "name",           :limit => 50
    t.string  "street_address", :limit => 50
    t.string  "locality",       :limit => 50
    t.string  "region",         :limit => 50
    t.string  "iso3",           :limit => 50
    t.string  "postal_code",    :limit => 50
    t.string  "phone",          :limit => 50
    t.string  "url",            :limit => 50
    t.string  "app_id",         :limit => 50
    t.string  "dataset_id",     :limit => 50
    t.integer "tweet_id",                     :null => false
  end

  add_index "geos", ["tweet_id"], :name => "index_geos_tweet"
  add_index "geos", ["twitter_id", "geo_id"], :name => "unique_geos_unique_geo", :unique => true

  create_table "graph_points", :force => true do |t|
    t.string  "label",                :limit => 50
    t.string  "value",                :limit => 50
    t.integer "curation_id"
    t.integer "graph_id"
    t.integer "analysis_metadata_id",               :null => false
  end

  add_index "graph_points", ["analysis_metadata_id"], :name => "index_graph_points_analysis_metadata"
  add_index "graph_points", ["curation_id", "graph_id"], :name => "index_graph_points_graph_id_curation_id"
  add_index "graph_points", ["curation_id"], :name => "index_graph_points_curation_id"
  add_index "graph_points", ["graph_id"], :name => "index_graph_points_graph_id"
  add_index "graph_points", ["label", "curation_id", "graph_id"], :name => "index_graph_points_label_graph_id_curation_id"
  add_index "graph_points", ["label", "curation_id"], :name => "index_graph_points_label_curation_id"
  add_index "graph_points", ["label", "value", "graph_id"], :name => "index_graph_points_label_value_graph_id"
  add_index "graph_points", ["label", "value"], :name => "index_graph_points_label_value"

  create_table "graphs", :force => true do |t|
    t.string   "title",                :limit => 50
    t.string   "style",                :limit => 50
    t.integer  "year"
    t.integer  "month"
    t.integer  "date"
    t.integer  "hour"
    t.boolean  "written",                            :default => false
    t.datetime "time_slice"
    t.integer  "analysis_metadata_id",                                  :null => false
    t.integer  "curation_id",                                           :null => false
  end

  add_index "graphs", ["analysis_metadata_id"], :name => "index_graphs_analysis_metadata"
  add_index "graphs", ["curation_id"], :name => "index_graphs_curation"
  add_index "graphs", ["date", "hour"], :name => "index_graphs_date_hour"
  add_index "graphs", ["date", "hour"], :name => "index_graphs_date_hour_graph"
  add_index "graphs", ["date"], :name => "index_graphs_date"
  add_index "graphs", ["date"], :name => "index_graphs_date_graph"
  add_index "graphs", ["hour"], :name => "index_graphs_hour"
  add_index "graphs", ["hour"], :name => "index_graphs_hour_graph"
  add_index "graphs", ["month", "date", "hour"], :name => "index_graphs_month_date_hour"
  add_index "graphs", ["month", "date", "hour"], :name => "index_graphs_month_date_hour_graph"
  add_index "graphs", ["month", "date"], :name => "index_graphs_month_date"
  add_index "graphs", ["month", "date"], :name => "index_graphs_month_date_graph"
  add_index "graphs", ["month"], :name => "index_graphs_month"
  add_index "graphs", ["month"], :name => "index_graphs_month_graph"
  add_index "graphs", ["style"], :name => "index_graphs_style_graph"
  add_index "graphs", ["time_slice"], :name => "index_graphs_time_slice_graph"
  add_index "graphs", ["title", "style", "year", "month", "date", "hour", "time_slice"], :name => "unique_graphs_unique_graph", :unique => true
  add_index "graphs", ["title"], :name => "index_graphs_title_graph"
  add_index "graphs", ["year", "month", "date", "hour"], :name => "index_graphs_year_month_date_hour"
  add_index "graphs", ["year", "month", "date", "hour"], :name => "index_graphs_year_month_date_hour_graph"
  add_index "graphs", ["year", "month", "date"], :name => "index_graphs_year_month_date"
  add_index "graphs", ["year", "month", "date"], :name => "index_graphs_year_month_date_graph"
  add_index "graphs", ["year", "month"], :name => "index_graphs_year_month"
  add_index "graphs", ["year", "month"], :name => "index_graphs_year_month_graph"
  add_index "graphs", ["year"], :name => "index_graphs_year"
  add_index "graphs", ["year"], :name => "index_graphs_year_graph"

  create_table "importer_tasks", :force => true do |t|
    t.string  "file_location", :limit => 50
    t.string  "type",          :limit => 50
    t.integer "researcher_id",               :default => 0
    t.integer "dataset_id"
    t.boolean "finished",                    :default => false
  end

  add_index "importer_tasks", ["type", "researcher_id"], :name => "unique_importer_tasks_unique_importer_task", :unique => true

  create_table "instances", :force => true do |t|
    t.string  "instance_id",   :limit => 40
    t.string  "hostname",      :limit => 50, :default => "[\"bundy\\n\"]"
    t.integer "pid",                         :default => 16638
    t.boolean "killed",                      :default => false
    t.string  "instance_type", :limit => 50
  end

  add_index "instances", ["hostname", "pid", "instance_type"], :name => "unique_instances_unique_instance", :unique => true

  create_table "locations", :force => true do |t|
    t.integer "woeid"
    t.string  "name",            :limit => 50
    t.integer "parent_id"
    t.integer "place_code"
    t.string  "place_code_name", :limit => 50
    t.string  "country",         :limit => 50
    t.string  "country_code",    :limit => 50
    t.integer "dataset_id"
  end

  create_table "locks", :force => true do |t|
    t.string  "classname",   :limit => 50
    t.integer "with_id"
    t.string  "instance_id", :limit => 40
  end

  add_index "locks", ["classname", "with_id"], :name => "index_locks_unique_metadata"

  create_table "mails", :force => true do |t|
    t.boolean "sent",            :default => false
    t.text    "message_content"
    t.text    "recipient"
    t.text    "subject"
    t.integer "researcher_id"
  end

  add_index "mails", ["researcher_id"], :name => "index_mails_researcher_id"

  create_table "parameters", :force => true do |t|
    t.integer "worker_description_id"
    t.string  "name",                  :limit => 50
    t.integer "position"
    t.text    "description"
    t.boolean "active"
  end

  create_table "posts", :force => true do |t|
    t.string   "title",         :limit => 50, :null => false
    t.string   "slug",          :limit => 50
    t.text     "text"
    t.datetime "created_at"
    t.integer  "researcher_id",               :null => false
  end

  add_index "posts", ["researcher_id"], :name => "index_posts_researcher"

  create_table "researchers", :force => true do |t|
    t.string   "user_name",                 :limit => 40
    t.text     "email"
    t.string   "reset_code",                :limit => 50
    t.string   "role",                      :limit => 50, :default => "Admin"
    t.datetime "join_date",                               :default => '2012-01-26 22:28:17'
    t.datetime "last_login"
    t.datetime "last_access"
    t.text     "info"
    t.text     "website_url"
    t.string   "location",                  :limit => 50, :default => "The Internet"
    t.string   "salt",                      :limit => 50
    t.string   "remember_token",            :limit => 50
    t.datetime "remember_token_expires_at"
    t.string   "crypted_password",          :limit => 50
    t.boolean  "share_email",                             :default => false
    t.boolean  "private_data",                            :default => false
    t.boolean  "hidden_account",                          :default => false
    t.boolean  "rate_limited",                            :default => false
    t.string   "uid",                       :limit => 10
    t.string   "provider",                  :limit => 40
    t.string   "name",                      :limit => 40
    t.string   "oauth_token",               :limit => 50
    t.string   "oauth_token_secret",        :limit => 42
  end

  add_index "researchers", ["uid"], :name => "unique_researchers_uid", :unique => true

  create_table "tickets", :force => true do |t|
    t.string   "title",         :limit => 50, :null => false
    t.text     "text"
    t.integer  "severity"
    t.datetime "created_at"
    t.integer  "researcher_id",               :null => false
  end

  add_index "tickets", ["researcher_id"], :name => "index_tickets_researcher"

  create_table "trending_topics", :force => true do |t|
    t.integer  "woeid"
    t.datetime "created_at"
    t.datetime "ended_at"
    t.string   "name",       :limit => 50
    t.integer  "dataset_id"
  end

  create_table "tweets", :force => true do |t|
    t.integer  "twitter_id",              :limit => 8
    t.integer  "user_id",                 :limit => 8
    t.text     "text"
    t.string   "language",                :limit => 50
    t.string   "screen_name",             :limit => 50
    t.text     "location"
    t.integer  "in_reply_to_status_id",   :limit => 8
    t.integer  "in_reply_to_user_id",     :limit => 8
    t.boolean  "truncated",                             :default => false
    t.string   "in_reply_to_screen_name", :limit => 50
    t.datetime "created_at"
    t.integer  "retweet_count"
    t.string   "lat",                     :limit => 50
    t.string   "lon",                     :limit => 50
    t.text     "source"
    t.boolean  "retweeted",                             :default => false
    t.integer  "dataset_id"
  end

  add_index "tweets", ["created_at", "dataset_id"], :name => "index_tweets_created_at_dataset"
  add_index "tweets", ["created_at"], :name => "index_tweets_created_at"
  add_index "tweets", ["dataset_id"], :name => "index_tweets_dataset_id"
  add_index "tweets", ["in_reply_to_screen_name", "dataset_id"], :name => "index_tweets_retweet_id_dataset"
  add_index "tweets", ["in_reply_to_screen_name"], :name => "index_tweets_retweet_id"
  add_index "tweets", ["in_reply_to_status_id", "dataset_id"], :name => "index_tweets_in_reply_to_status_id_dataset"
  add_index "tweets", ["in_reply_to_status_id"], :name => "index_tweets_in_reply_to_status_id"
  add_index "tweets", ["in_reply_to_user_id", "dataset_id"], :name => "index_tweets_in_reply_to_user_id_dataset"
  add_index "tweets", ["in_reply_to_user_id"], :name => "index_tweets_in_reply_to_user_id"
  add_index "tweets", ["language", "dataset_id"], :name => "index_tweets_language_dataset"
  add_index "tweets", ["language"], :name => "index_tweets_language"
  add_index "tweets", ["lat", "dataset_id"], :name => "index_tweets_lat_dataset"
  add_index "tweets", ["lat"], :name => "index_tweets_lat"
  add_index "tweets", ["lon", "dataset_id"], :name => "index_tweets_lon_dataset"
  add_index "tweets", ["lon"], :name => "index_tweets_lon"
  add_index "tweets", ["retweet_count", "dataset_id"], :name => "index_tweets_retweet_count_dataset"
  add_index "tweets", ["retweet_count"], :name => "index_tweets_retweet_count"
  add_index "tweets", ["retweeted", "dataset_id"], :name => "index_tweets_retweeted_dataset"
  add_index "tweets", ["retweeted"], :name => "index_tweets_retweeted"
  add_index "tweets", ["screen_name", "dataset_id"], :name => "index_tweets_screen_name_dataset"
  add_index "tweets", ["screen_name"], :name => "index_tweets_screen_name"
  add_index "tweets", ["truncated", "dataset_id"], :name => "index_tweets_truncated_dataset"
  add_index "tweets", ["truncated"], :name => "index_tweets_truncated"
  add_index "tweets", ["twitter_id", "dataset_id"], :name => "index_tweets_twitter_id_dataset"
  add_index "tweets", ["twitter_id", "dataset_id"], :name => "unique_tweets_unique_tweet", :unique => true
  add_index "tweets", ["twitter_id"], :name => "index_tweets_twitter_id"
  add_index "tweets", ["user_id", "dataset_id"], :name => "index_tweets_user_id_dataset"
  add_index "tweets", ["user_id"], :name => "index_tweets_user_id"

  create_table "users", :force => true do |t|
    t.integer  "twitter_id",                   :limit => 8
    t.string   "name",                         :limit => 50
    t.string   "screen_name",                  :limit => 50
    t.text     "location"
    t.string   "description",                  :limit => 50
    t.string   "profile_image_url",            :limit => 50
    t.text     "url"
    t.boolean  "protected"
    t.integer  "followers_count"
    t.string   "profile_background_color",     :limit => 50
    t.string   "profile_text_color",           :limit => 50
    t.string   "profile_link_color",           :limit => 50
    t.string   "profile_sidebar_fill_color",   :limit => 50
    t.string   "profile_sidebar_border_color", :limit => 50
    t.integer  "friends_count"
    t.datetime "created_at"
    t.integer  "favourites_count"
    t.integer  "utc_offset"
    t.string   "time_zone",                    :limit => 50
    t.string   "profile_background_image_url", :limit => 50
    t.boolean  "profile_background_tile",                    :default => false
    t.boolean  "profile_use_background_image",               :default => false
    t.boolean  "show_all_inline_media",                      :default => false
    t.boolean  "is_translator",                              :default => false
    t.boolean  "notifications",                              :default => false
    t.boolean  "geo_enabled",                                :default => false
    t.boolean  "verified",                                   :default => false
    t.boolean  "following",                                  :default => false
    t.integer  "statuses_count"
    t.boolean  "contributors_enabled",                       :default => false
    t.boolean  "default_profile",                            :default => false
    t.text     "default_profile_image"
    t.string   "lang",                         :limit => 50
    t.integer  "listed_count"
    t.boolean  "follow_request_sent",                        :default => false
    t.integer  "dataset_id",                                                    :null => false
  end

  add_index "users", ["contributors_enabled"], :name => "index_users_contributors_enabled"
  add_index "users", ["contributors_enabled"], :name => "index_users_contributors_enabled_dataset"
  add_index "users", ["created_at"], :name => "index_users_created_at"
  add_index "users", ["created_at"], :name => "index_users_created_at_dataset"
  add_index "users", ["dataset_id"], :name => "index_users_dataset"
  add_index "users", ["default_profile"], :name => "index_users_default_profile"
  add_index "users", ["default_profile"], :name => "index_users_default_profile_dataset"
  add_index "users", ["description"], :name => "index_users_description"
  add_index "users", ["favourites_count"], :name => "index_users_favorites_count"
  add_index "users", ["favourites_count"], :name => "index_users_favorites_count_dataset"
  add_index "users", ["follow_request_sent"], :name => "index_users_follow_request_sent"
  add_index "users", ["follow_request_sent"], :name => "index_users_follow_request_sent_dataset"
  add_index "users", ["followers_count"], :name => "index_users_followers_count"
  add_index "users", ["followers_count"], :name => "index_users_followers_count_dataset"
  add_index "users", ["following"], :name => "index_users_following"
  add_index "users", ["following"], :name => "index_users_following_dataset"
  add_index "users", ["friends_count"], :name => "index_users_friends_count"
  add_index "users", ["friends_count"], :name => "index_users_friends_count_dataset"
  add_index "users", ["geo_enabled"], :name => "index_users_geo_enabled"
  add_index "users", ["geo_enabled"], :name => "index_users_geo_enabled_dataset"
  add_index "users", ["is_translator"], :name => "index_users_is_translator"
  add_index "users", ["is_translator"], :name => "index_users_is_translator_dataset"
  add_index "users", ["lang"], :name => "index_users_lang"
  add_index "users", ["lang"], :name => "index_users_lang_dataset"
  add_index "users", ["listed_count"], :name => "index_users_listed_count"
  add_index "users", ["listed_count"], :name => "index_users_listed_count_dataset"
  add_index "users", ["name"], :name => "index_users_name"
  add_index "users", ["notifications"], :name => "index_users_notifications"
  add_index "users", ["notifications"], :name => "index_users_notifications_dataset"
  add_index "users", ["profile_background_color"], :name => "index_users_profile_background_color"
  add_index "users", ["profile_background_color"], :name => "index_users_profile_background_color_dataset"
  add_index "users", ["profile_background_image_url"], :name => "index_users_profile_background_image_url"
  add_index "users", ["profile_background_tile"], :name => "index_users_profile_background_tile"
  add_index "users", ["profile_background_tile"], :name => "index_users_profile_background_tile_dataset"
  add_index "users", ["profile_image_url"], :name => "index_users_profile_image_url"
  add_index "users", ["profile_link_color"], :name => "index_users_profile_link_color"
  add_index "users", ["profile_link_color"], :name => "index_users_profile_link_color_dataset"
  add_index "users", ["profile_sidebar_border_color"], :name => "index_users_profile_sidebar_border_color"
  add_index "users", ["profile_sidebar_border_color"], :name => "index_users_profile_sidebar_border_color_dataset"
  add_index "users", ["profile_sidebar_fill_color"], :name => "index_users_profile_sidebar_fill_color"
  add_index "users", ["profile_sidebar_fill_color"], :name => "index_users_profile_sidebar_fill_color_dataset"
  add_index "users", ["profile_text_color"], :name => "index_users_profile_text_color"
  add_index "users", ["profile_text_color"], :name => "index_users_profile_text_color_dataset"
  add_index "users", ["profile_use_background_image"], :name => "index_users_profile_use_background_image"
  add_index "users", ["profile_use_background_image"], :name => "index_users_profile_use_background_image_dataset"
  add_index "users", ["protected"], :name => "index_users_protected"
  add_index "users", ["protected"], :name => "index_users_protected_dataset"
  add_index "users", ["screen_name"], :name => "index_users_screen_name"
  add_index "users", ["show_all_inline_media"], :name => "index_users_show_all_inline_media"
  add_index "users", ["show_all_inline_media"], :name => "index_users_show_all_inline_media_dataset"
  add_index "users", ["statuses_count"], :name => "index_users_statuses_count"
  add_index "users", ["statuses_count"], :name => "index_users_statuses_count_dataset"
  add_index "users", ["time_zone"], :name => "index_users_time_zone"
  add_index "users", ["time_zone"], :name => "index_users_time_zone_dataset"
  add_index "users", ["twitter_id"], :name => "index_users_twitter_id"
  add_index "users", ["twitter_id"], :name => "index_users_twitter_id_dataset"
  add_index "users", ["twitter_id"], :name => "unique_users_unique_user", :unique => true
  add_index "users", ["utc_offset"], :name => "index_users_utc_offset"
  add_index "users", ["utc_offset"], :name => "index_users_utc_offset_dataset"
  add_index "users", ["verified"], :name => "index_users_verified"
  add_index "users", ["verified"], :name => "index_users_verified_dataset"

  create_table "whitelistings", :id => false, :force => true do |t|
    t.integer "id",                                                      :null => false
    t.string  "hostname",    :limit => 50, :default => "[\"bundy\\n\"]", :null => false
    t.string  "ip",          :limit => 50
    t.boolean "whitelisted",               :default => false
  end

  add_index "whitelistings", ["hostname", "ip", "whitelisted"], :name => "unique_whitelistings_unique_whitelisting", :unique => true
  add_index "whitelistings", ["id"], :name => "unique_whitelistings_key", :unique => true

  create_table "worker_descriptions", :force => true do |t|
    t.string  "name",        :limit => 50
    t.string  "filename",    :limit => 50
    t.text    "description"
    t.string  "type",        :limit => 50
    t.boolean "active"
  end

end
