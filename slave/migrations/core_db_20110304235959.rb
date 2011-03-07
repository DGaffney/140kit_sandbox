migration 1, :core_db_20110304235959 do
  up do
    create_table :analysis_metadatas do
      column :id,   DataMapper::Property::Integer, :serial => true
      column :function, DataMapper::Property::String, :unique_index => [:unique_metadata]
      column :finished, DataMapper::Property::Boolean
      column :rest, DataMapper::Property::Boolean
      column :curation_id, DataMapper::Property::Integer, :unique_index => [:unique_metadata]
      column :save_path, DataMapper::Property::String
    end
    create_table :analytical_offerings do
      column :id, DataMapper::Property::Serial, :serial => true
      column :title, DataMapper::Property::String, :index => [:unique_metadata]
      column :description, DataMapper::Property::Text, :index => [:unique_metadata]
      column :function, DataMapper::Property::String, :index => [:unique_analytical_offering]
      column :rest, DataMapper::Property::Boolean, :index => [:unique_metadata]
      column :source_code_link, DataMapper::Property::String, :index => [:unique_metadata]
      column :created_by, DataMapper::Property::String, :index => [:unique_metadata]
      column :created_by_link, DataMapper::Property::String, :index => [:unique_metadata]
      column :enabled, DataMapper::Property::Boolean, :index => [:unique_metadata]
      column :save_path, DataMapper::Property::String, :index => [:unique_metadata]
      column :language, DataMapper::Property::String, :index => [:unique_analytical_offering]
      column :access_level, DataMapper::Property::String, :index => [:unique_metadata]
    end
    create_table :analytical_offering_variables do
      column :id, DataMapper::Property::Serial, :serial => true
      column :order, DataMapper::Property::Integer, :unique_index => [:unique_analytical_offering_variable]
      column :analysis_metadata_id, DataMapper::Property::Integer, :unique_index => [:unique_analytical_offering_variable]
      column :value, DataMapper::Property::String, :unique_index => [:unique_analytical_offering_variable]
      column :kind, DataMapper::Property::String, :unique_index => [:unique_analytical_offering_variable]
    end
    create_table :edges do 
      column :id, DataMapper::Property::Serial, :serial => true
      column :start_node, DataMapper::Property::String, :unique_index => [:unique_edge], :index => [:start_node_edge, :start_node]
      column :end_node, DataMapper::Property::String, :unique_index => [:unique_edge], :index => [:end_node_edge, :end_node]
      column :edge_id, DataMapper::Property::String, :unique_index => [:unique_edge], :index => [:edge_id_edge, :edge_id]
      column :time, DataMapper::Property::DateTime, :unique_index => [:unique_edge], :index => [:time_edge, :time]
      column :graph_id, DataMapper::Property::Integer, :unique_index => [:unique_edge], :index => [:start_node_edge, :end_node_edge, :edge_id_edge, :time_edge]
      column :curation_id, DataMapper::Property::Integer, :unique_index => [:unique_edge], :index => [:curation_edge]
      column :flagged, DataMapper::Property::Boolean
      column :style, DataMapper::Property::String
    end
    create_table :graphs do 
      column :id, DataMapper::Property::Serial, :serial => true
      column :title, DataMapper::Property::String, :unique_index => [:unique_graph], :index => [:title_graph]
      column :style, DataMapper::Property::String, :unique_index => [:unique_graph], :index => [:style_graph]
      column :curation_id, DataMapper::Property::Integer, :unique_index => [:unique_graph], :index => [:curation_id_graph, :year_month_date_hour_graph, :year_month_date_graph, :year_month_graph, :month_date_hour_graph, :month_date_graph, :date_hour_graph, :year_graph, :month_graph, :date_graph, :hour_graph]
      column :year, DataMapper::Property::Integer, :unique_index => [:unique_graph], :index => [:year_graph, :year_month_date_hour_graph, :year_month_date_graph, :year_month_graph, :year_month_date_hour, :year_month_date, :year_month, :year]
      column :month, DataMapper::Property::Integer, :unique_index => [:unique_graph], :index => [:month_graph, :year_month_date_hour_graph, :year_month_date_graph, :year_month_graph, :month_date_hour_graph, :month_date_graph, :year_month_date_hour, :year_month_date, :year_month, :month_date_hour, :month_date, :month]
      column :date, DataMapper::Property::Integer, :unique_index => [:unique_graph], :index => [:date_graph, :year_month_date_hour_graph, :year_month_date_graph, :month_date_hour_graph, :date_hour_graph, :month_date_graph, :year_month_date_hour, :year_month_date, :month_date_hour, :month_date, :date_hour, :date]
      column :hour, DataMapper::Property::Integer, :unique_index => [:unique_graph], :index => [:hour_graph, :year_month_date_hour_graph, :month_date_hour_graph, :date_hour_graph, :year_month_date_hour, :month_date_hour, :date_hour, :hour]
      column :written, DataMapper::Property::Boolean
      column :time_slice, DataMapper::Property::DateTime, :unique_index => [:unique_graph], :index => [:time_slice_graph]
    end
    create_table :graph_points do
      column :id, DataMapper::Property::Serial, :serial => true
      column :label, DataMapper::Property::String, :unique_index => [:unique_graph_point], :index => [:label_value_graph_id, :label_value, :label_curation_id, :label_graph_id_curation_id]
      column :value, DataMapper::Property::Float, :unique_index => [:unique_graph_point], :index => [:label_value_graph_id, :label_value]
      column :graph_id, DataMapper::Property::Integer, :unique_index => [:unique_graph_point], :index => [:label_value_graph_id, :label_graph_id_curation_id, :graph_id, :graph_id_curation_id]
      column :curation_id, DataMapper::Property::Integer, :unique_index => [:unique_graph_point], :index => [:label_curation_id, :label_graph_id_curation_id, :curation_id, :graph_id_curation_id]
    end
    create_table :auth_users do
      column :id, DataMapper::Property::Serial, :serial => true
      column :user_name, DataMapper::Property::String, :unique_index => [:unique_auth_user]
      column :password, DataMapper::Property::String, :unique_index => [:unique_auth_user]
      column :instance_id, DataMapper::Property::String
      column :hostname, DataMapper::Property::String
    end
    create_table :curations do
      column :id, DataMapper::Property::Serial, :serial => true
      column :name, DataMapper::Property::String, :unique_index => [:unique_curation]
      column :researcher_id, DataMapper::Property::Integer, :unique_index => [:unique_curation], :index => [:researcher_id, :researcher_id_analyzed, :researcher_id_single_dataset]
      column :single_dataset, DataMapper::Property::Boolean, :index => [:researcher_id_single_dataset]
      column :analyzed, DataMapper::Property::Boolean, :index => [:researcher_id_analyzed]
      column :created_at, DataMapper::Property::DateTime, :unique_index => [:unique_curation]
      column :updated_at, DataMapper::Property::DateTime
    end
    create_table :datasets_curations do 
      column :dataset_id, DataMapper::Property::Integer, :unique_index => [:unique_dataset_curation], :index => [:dataset_id]
      column :curation_id, DataMapper::Property::Integer, :unique_index => [:unique_dataset_curation], :index => [:curation_id]
    end
    create_table :datasets do
      column :id, DataMapper::Property::Serial, :serial => true
      column :scrape_type, DataMapper::Property::String, :index => [:scrape_type, :scrape_method_scrape_type]
      column :start_time, DataMapper::Property::DateTime
      column :length, DataMapper::Property::Integer
      column :created_at, DataMapper::Property::DateTime
      column :updated_at, DataMapper::Property::DateTime
      column :scrape_finished, DataMapper::Property::Boolean
      column :scrape_method, DataMapper::Property::String, :index => [:scrape_method, :scrape_method_scrape_type]
      column :instance_id, DataMapper::Property::String, :index => [:instance_id]
      column :params, DataMapper::Property::String
      column :tweets_count, DataMapper::Property::Integer
      column :users_count, DataMapper::Property::Integer
    end
    create_table :instances do
      column :id,             DataMapper::Property::Serial, :serial => true
      column :instance_id,    DataMapper::Property::String, :length => 40
      column :hostname,       DataMapper::Property::String, :unique_index => [:unique_instance]
      column :pid,            DataMapper::Property::Integer, :unique_index => [:unique_instance]
      column :killed,         DataMapper::Property::Boolean
      column :instance_type,  DataMapper::Property::String, :unique_index => [:unique_instance]
    end
    create_table :locks do
      column :id, DataMapper::Property::Serial, :serial => true
      column :classname, DataMapper::Property::String, :index => [:unique_metadata]
      column :with_id, DataMapper::Property::Integer, :index => [:unique_metadata]
      column :instance_id, DataMapper::Property::String, :length => 40
    end
    create_table :tweets do
      column :id,           DataMapper::Property::Serial, :serial => true
      column :twitter_id,   DataMapper::Property::Integer, :index => [:twitter_id_dataset, :twitter_id], :unique_index => [:unique_tweet]
      column :text,         DataMapper::Property::Text, :index => [:text_dataset, :text]
      column :language,     DataMapper::Property::String, :index => [:language_dataset, :language]
      column :user_id,      DataMapper::Property::Integer, :index => [:user_id_dataset, :user_id]
      column :screen_name,  DataMapper::Property::String, :index => [:screen_name_dataset, :screen_name]
      column :location,     DataMapper::Property::Text, :index => [:location_dataset, :location]
      column :in_reply_to_status_id, DataMapper::Property::Integer, :index => [:in_reply_to_status_id_dataset, :in_reply_to_status_id]
      column :in_reply_to_user_id,   DataMapper::Property::Integer, :index => [:in_reply_to_user_id_dataset, :in_reply_to_user_id]
      column :truncated,    DataMapper::Property::Boolean, :index => [:truncated_dataset, :truncated]
      column :in_reply_to_screen_name, DataMapper::Property::String, :index => [:retweet_id_dataset, :retweet_id]
      column :created_at,   DataMapper::Property::DateTime, :index => [:created_at_dataset, :created_at]
      column :retweet_count,  DataMapper::Property::Integer, :index => [:retweet_count_dataset, :retweet_count]
      column :lat,          DataMapper::Property::String, :index => [:lat_dataset, :lat]
      column :lon,          DataMapper::Property::String, :index => [:lon_dataset, :lon]
      column :retweeted,  DataMapper::Property::Boolean, :index => [:retweeted_dataset, :retweeted]
      column :dataset_id,   DataMapper::Property::Integer, :unique_index => [:unique_tweet], :index => [:dataset_id, :twitter_id_dataset, :text_dataset, :language_dataset, :user_id_dataset, :screen_name_dataset, :location_dataset, :in_reply_to_status_id_dataset, :in_reply_to_user_id_dataset, :truncated_dataset, :retweet_id_dataset, :created_at_dataset, :retweet_count_dataset, :lat_dataset, :lon_dataset, :retweeted_dataset]
    end
    create_table :users do
      column :id, DataMapper::Property::Serial, :serial => true
      column :twitter_id, DataMapper::Property::Integer, :index => [:twitter_id_dataset, :twitter_id], :unique_index => [:unique_user]
      column :name, DataMapper::Property::String, :index => [:name]
      column :screen_name, DataMapper::Property::String, :index => [:screen_name]
      column :location, DataMapper::Property::Text, :index => [:location_dataset, :location]
      column :description, DataMapper::Property::String, :index => [:description]
      column :profile_image_url, DataMapper::Property::String, :index => [:profile_image_url]
      column :url, DataMapper::Property::Text, :index => [:url_dataset, :url]
      column :protected, DataMapper::Property::Boolean, :index => [:protected_dataset, :protected]
      column :followers_count, DataMapper::Property::Integer, :index => [:followers_count_dataset, :followers_count]
      column :profile_background_color, DataMapper::Property::String, :index => [:profile_background_color_dataset, :profile_background_color]
      column :profile_text_color, DataMapper::Property::String, :index => [:profile_text_color_dataset, :profile_text_color]
      column :profile_link_color, DataMapper::Property::String, :index => [:profile_link_color_dataset, :profile_link_color]
      column :profile_sidebar_fill_color, DataMapper::Property::String, :index => [:profile_sidebar_fill_color_dataset, :profile_sidebar_fill_color]
      column :profile_sidebar_border_color, DataMapper::Property::String, :index => [:profile_sidebar_border_color_dataset, :profile_sidebar_border_color]
      column :friends_count, DataMapper::Property::Integer, :index => [:friends_count_dataset, :friends_count]
      column :created_at, DataMapper::Property::DateTime, :index => [:created_at_dataset, :created_at]
      column :favourites_count, DataMapper::Property::Integer, :index => [:favorites_count_dataset, :favorites_count]
      column :utc_offset, DataMapper::Property::Integer, :index => [:utc_offset_dataset, :utc_offset]
      column :time_zone, DataMapper::Property::String, :index => [:time_zone_dataset, :time_zone]
      column :profile_background_image_url, DataMapper::Property::String, :index => [:profile_background_image_url]
      column :profile_background_tile, DataMapper::Property::Boolean, :index => [:profile_background_tile_dataset, :profile_background_tile]
      column :profile_use_background_image, DataMapper::Property::Boolean, :index => [:profile_use_background_image_dataset, :profile_use_background_image]
      column :show_all_inline_media, DataMapper::Property::Boolean, :index => [:show_all_inline_media_dataset, :show_all_inline_media]
      column :is_translator, DataMapper::Property::Boolean, :index => [:is_translator_dataset, :is_translator]
      column :notifications, DataMapper::Property::Boolean, :index => [:notifications_dataset, :notifications]
      column :geo_enabled, DataMapper::Property::Boolean, :index => [:geo_enabled_dataset, :geo_enabled]
      column :verified, DataMapper::Property::Boolean, :index => [:verified_dataset, :verified]
      column :following, DataMapper::Property::Boolean, :index => [:following_dataset, :following]
      column :statuses_count, DataMapper::Property::Integer, :index => [:statuses_count_dataset, :statuses_count]
      column :contributors_enabled, DataMapper::Property::Boolean, :index => [:contributors_enabled_dataset, :contributors_enabled]
      column :lang, DataMapper::Property::String, :index => [:lang_dataset, :lang]
      column :listed_count, DataMapper::Property::Integer, :index => [:listed_count_dataset, :listed_count]
      column :follow_request_sent, DataMapper::Property::Boolean, :index => [:follow_request_sent_dataset, :follow_request_sent]
      column :dataset_id, DataMapper::Property::Integer, :unique_index => [:unique_user], :index => [:location_dataset, :url_dataset, :protected_dataset, :followers_count_dataset, :profile_background_color_dataset, :profile_text_color_dataset, :profile_link_color_dataset, :profile_sidebar_fill_color_dataset, :profile_sidebar_border_color_dataset, :friends_count_dataset, :created_at_dataset, :favorites_count_dataset, :utc_offset_dataset, :time_zone_dataset, :profile_background_tile_dataset, :profile_use_background_image_dataset, :show_all_inline_media_dataset, :is_translator_dataset, :notifications_dataset, :geo_enabled_dataset, :verified_dataset, :following_dataset, :statuses_count_dataset, :contributors_enabled_dataset, :lang_dataset, :listed_count_dataset, :follow_request_sent_dataset]
    end
    create_table :whitelistings do
      column :hostname, DataMapper::Property::String, :key => true, :unique_index => [:unique_whitelisting]
      column :ip, DataMapper::Property::String, :unique_index => [:unique_whitelisting]
      column :whitelisted, DataMapper::Property::Boolean, :default => 0, :unique_index => [:unique_whitelisting]
    end
  end

  down do
    drop_table :analysis_metadatas
    drop_table :analytical_offerings
    drop_table :analytical_offering_variables
    drop_table :edges
    drop_table :graphs
    drop_table :graph_points
    drop_table :auth_users
    drop_table :curations
    drop_table :datasets_curations
    drop_table :datasets
    drop_table :instances
    drop_table :locks
    drop_table :tweets
    drop_table :users
    drop_table :whitelistings
  end
end

migrate_up!