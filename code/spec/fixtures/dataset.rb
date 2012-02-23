types = {"track" => "#{/\w+/.gen[5..25]}", "follow" => "#{/\w+/.gen[5..25]},#{/\w+/.gen[5..25]},#{/\w+/.gen[5..25]},#{/\w+/.gen[5..25]}", "locations" => "#{rand*rand(100)}, #{rand*rand(100)}"}
Dataset.fix{{
  :scrape_type => type = types.keys.shuffle.first,
  :created_at => time = (Time.now-(rand(100)-100).days),
  :start_time => start_time = (time+(rand(80)+20).days),
  :length => length = rand(604800),
  :updated_at => time+rand(20).days,
  :scrape_finished => Time.now<=start_time+length,
  :params => types[type],
  :tweets_count => rand(50000000),
  :users_count => rand(50000000)
}}

Dataset.fix(:finished){{
  :scrape_type => type = types.keys.shuffle.first,
  :created_at => time = (Time.now-(rand(100)-100).days),
  :start_time => start_time = (time+(rand(80)+20).days),
  :length => length = rand(10),
  :updated_at => time+rand(20).days,
  :scrape_finished => true,
  :params => types[type],
  :tweets_count => rand(50000000),
  :users_count => rand(50000000)
}}

