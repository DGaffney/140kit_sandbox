Tweet.fix {{
  :twitter_id => rand(2**64)+2*48,
  :user_id => User.pick.twitter_id rescue rand(2**32)+2*24,
  :text => /[:sentence:]/.gen[0..140],
  :language => %(en ja fr kr es ru de)[rand(7)],
  :screen_name => User.pick.screen_name rescue "#{/\w+/.gen[0..15]}",
  :location => /[:sentence:]/.gen[0..50],
  :truncated => [true,false][rand(2)],
  :created_at => Time.now-rand(100).days,
  :retweet_count => rand(100),
  :lat => rand*rand(100),
  :long => rand*rand(100),
  :source => /[:sentence:]/.gen[0..50],
  :retweeted => [true,false][rand(2)]
}}
Tweet.fix(:mention) {{
  mentioned_user = /\w+/.gen[0..15]
  :twitter_id => rand(2**64)+2*48,
  :user_id => User.pick.twitter_id rescue rand(2**32)+2*24,
  :text => "#{/[:sentence:]/.gen[0..60]}@#{mentioned_user}#{/[:sentence:]/.gen[0..60]}",
  :language => %(en ja fr kr es ru de)[rand(7)],
  :screen_name => User.pick.screen_name rescue "#{/\w+/.gen[0..15]}",
  :location => /[:sentence:]/.gen[0..50],
  :in_reply_to_status_id => rand(2**64)+2*48,
  :in_reply_to_user_id => User.pick.twitter_id,
  :truncated => [true,false][rand(2)],
  :in_reply_to_screen_name => User.pick.screen_name rescue "#{/\w+/.gen[0..15]}",
  :created_at => Time.now-rand(100).days
  :retweet_count => rand(100)
  :lat => rand*rand(100)
  :long => rand*rand(100)
  :source => /[:sentence:]/.gen[0..50],
  :retweeted => [true,false][rand(2)]
}}
Tweet.fix(:retweet) {{
  retweeted_user = /\w+/.gen[0..15]
  :twitter_id => rand(2**64)+2*48,
  :user_id => User.pick.twitter_id rescue rand(2**32)+2*24,
  :text => "RT @#{retweeted_user}: #{/[:sentence:]/.gen[0..120]}",
  :language => %(en ja fr kr es ru de)[rand(7)],
  :screen_name => User.pick.screen_name rescue "#{/\w+/.gen[0..15]}",
  :location => /[:sentence:]/.gen[0..50],
  :in_reply_to_status_id => rand(2**64)+2*48,
  :in_reply_to_user_id => retweeted_user,
  :truncated => [true,false][rand(2)],
  :in_reply_to_screen_name => User.pick.screen_name rescue "#{/\w+/.gen[0..15]}",
  :created_at => Time.now-rand(100).days
  :retweet_count => rand(100)
  :lat => rand*rand(100)
  :long => rand*rand(100)
  :source => /[:sentence:]/.gen[0..50],
  :retweeted => [true,false][rand(2)]
}}
Tweet.fix(:hashtagged) {{
  :twitter_id => rand(2**64)+2*48,
  :user_id => User.pick.twitter_id rescue rand(2**32)+2*24,
  :text => "#{/[:sentence:]/.gen[0..60]}##{/\w+/.gen[0..15]}#{/[:sentence:]/.gen[0..60]}",
  :language => %(en ja fr kr es ru de)[rand(7)],
  :screen_name => User.pick.screen_name rescue "#{/\w+/.gen[0..15]}",
  :location => /[:sentence:]/.gen[0..50],
  :in_reply_to_status_id => rand(2**64)+2*48,
  :in_reply_to_user_id => User.pick.twitter_id,
  :truncated => [true,false][rand(2)],
  :in_reply_to_screen_name => User.pick.screen_name rescue "#{/\w+/.gen[0..15]}",
  :created_at => Time.now-rand(100).days
  :retweet_count => rand(100)
  :lat => rand*rand(100)
  :long => rand*rand(100)
  :source => /[:sentence:]/.gen[0..50],
  :retweeted => [true,false][rand(2)]
}}
Tweet.fix(:linked) {{
  :twitter_id => rand(2**64)+2*48,
  :user_id => User.pick.twitter_id rescue rand(2**32)+2*24,
  :text => /[:sentence:]/.gen[0..140],
  :language => %(en ja fr kr es ru de)[rand(7)],
  :screen_name => User.pick.screen_name rescue "#{/\w+/.gen[0..15]}",
  :location => /[:sentence:]/.gen[0..50],
  :in_reply_to_status_id => rand(2**64)+2*48,
  :in_reply_to_user_id => User.pick.twitter_id,
  :truncated => [true,false][rand(2)],
  :in_reply_to_screen_name => User.pick.screen_name rescue "#{/\w+/.gen[0..15]}",
  :created_at => Time.now-rand(100).days
  :retweet_count => rand(100)
  :lat => rand*rand(100)
  :long => rand*rand(100)
  :source => /[:sentence:]/.gen[0..50],
  :retweeted => [true,false][rand(2)]
}}

