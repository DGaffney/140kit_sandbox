Friendship.fix {{
  :dataset_id => Dataset.pick.id,
  :followed_user_name => (followed_user = User.pick).screen_name,
  :follower_user_name => (follower_user = User.pick).screen_name,
  :followed_user_id => followed_user.twitter_id,
  :follower_user_id => follower_user.twitter_id,
  :created_at => Time.now
}}