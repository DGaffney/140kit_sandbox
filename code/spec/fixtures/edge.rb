Edge.fix{{
  :start_node => (user = User.pick).screen_name,
  :end_node => User.pick.screen_name,
  :edge_id => user.tweets.shuffle.first&&user.tweets.shuffle.first.twitter_id,
  :flagged => false,
  :style => "retweet"
}}