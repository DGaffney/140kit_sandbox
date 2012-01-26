Entity.fix{{
  :dataset_id => dataset = Dataset.pick.id,
  :twitter_id => dataset.tweets.shuffle.first&&dataset.tweets.shuffle.first.twitter_id,
  :kind => /\w+/.gen[5..25],
  :name => /\w+/.gen[5..25],
  :value => /\w+/.gen[5..25]
}}