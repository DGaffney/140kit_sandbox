Tweet.fix {{
  :twitter_id => rand(2**64)+2*48,
  :user_id => (this_user = User.pick).twitter_id,
  :text => /[:sentence:]/.gen[0..140],
  :language => %(en ja fr kr es ru de)[rand(7)],
  :screen_name => this_user.screen_name,
  :location => /[:sentence:]/.gen[0..50],
  :truncated => [true,false][rand(2)],
  :created_at => this_user.created_at+rand(((Time.now-this_user.created_at)/60/60/24)).days+rand(86400),
  :retweet_count => rand(100),
  :lat => rand*rand(100),
  :long => rand*rand(100),
  :source => /[:sentence:]/.gen[0..50],
  :retweeted => [true,false][rand(2)]
}}
Tweet.fix(:mention) {{
  :twitter_id => rand(2**64)+2*48,
  :user_id => (this_user = User.pick).twitter_id,
  :text => "#{/[:sentence:]/.gen[0..60]}@#{user.screen_name}#{/[:sentence:]/.gen[0..60]}",
  :language => %(en ja fr kr es ru de)[rand(7)],
  :screen_name => this_user.screen_name,
  :location => /[:sentence:]/.gen[0..50],
  :in_reply_to_status_id => rand(2**64)+2*48,
  :in_reply_to_user_id => (mentioned_user = User.pick).twitter_id,
  :truncated => [true,false][rand(2)],
  :in_reply_to_screen_name => mentioned_user.screen_name,
  :created_at => this_user.created_at+rand(((Time.now-this_user.created_at)/60/60/24)).days+rand(86400),
  :retweet_count => rand(100),
  :lat => rand*rand(100),
  :long => rand*rand(100),
  :source => /[:sentence:]/.gen[0..50],
  :retweeted => [true,false][rand(2)]
}}
Tweet.fix(:retweet) {{
  :twitter_id => rand(2**64)+2*48,
  :user_id => (this_user = User.pick).twitter_id,
  :text => "RT @#{retweeted_user}: #{/[:sentence:]/.gen[0..120]}",
  :language => %(en ja fr kr es ru de)[rand(7)],
  :screen_name => this_user.screen_name,
  :location => /[:sentence:]/.gen[0..50],
  :in_reply_to_user_id => (retweeted_user = User.pick).tweets.shuffle.first.twitter_id,
  :in_reply_to_user_id => retweeted_user.twitter_id,
  :truncated => [true,false][rand(2)],
  :in_reply_to_user_id => retweeted_user.twitter_id,
  :created_at => this_user.created_at+rand(((Time.now-this_user.created_at)/60/60/24)).days+rand(86400),
  :retweet_count => rand(100),
  :lat => rand*rand(100),
  :long => rand*rand(100),
  :source => /[:sentence:]/.gen[0..50],
  :retweeted => [true,false][rand(2)]
}}
Tweet.fix(:hashtagged) {{
  :twitter_id => rand(2**64)+2*48,
  :user_id => (this_user = User.pick).twitter_id,
  :text => "#{/[:sentence:]/.gen[0..60]}##{/\w+/.gen[0..15]}#{/[:sentence:]/.gen[0..60]}",
  :language => %(en ja fr kr es ru de)[rand(7)],
  :screen_name => this_user.screen_name,
  :location => /[:sentence:]/.gen[0..50],
  :truncated => [true,false][rand(2)],
  :created_at => this_user.created_at+rand(((Time.now-this_user.created_at)/60/60/24)).days+rand(86400),
  :retweet_count => rand(100),
  :lat => rand*rand(100),
  :long => rand*rand(100),
  :source => /[:sentence:]/.gen[0..50],
  :retweeted => [true,false][rand(2)]
}}
Tweet.fix(:linked) {{
  :twitter_id => rand(2**64)+2*48,
  :user_id => (this_user = User.pick).twitter_id,
  :text => /[:sentence:]/.gen[0..140],
  :language => %(en ja fr kr es ru de)[rand(7)],
  :screen_name => this_user.screen_name,
  :location => /[:sentence:]/.gen[0..50],
  :truncated => [true,false][rand(2)],
  :created_at => this_user.created_at+rand(((Time.now-this_user.created_at)/60/60/24)).days+rand(86400),
  :retweet_count => rand(100),
  :lat => rand*rand(100),
  :long => rand*rand(100),
  :source => /[:sentence:]/.gen[0..50],
  :retweeted => [true,false][rand(2)]
}}

