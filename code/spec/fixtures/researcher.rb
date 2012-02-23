Researcher.fix {{
  :user_name            => unique {/\w+/.gen},
  :email   => unique {"#{/\w+/.gen}@#{/\w{10}/.gen}.#{/\w{3}/.gen}"},
  :role => ["Admin", "Commercial Account", "User"][rand(3)],
  :join_date => Time.now-(rand(100)+100).days,
  :last_login => Time.now-rand(100).days,
  :last_access => Time.now-rand(100).days,
  :info => /[:sentence:]/.gen[0..500],
  :website_url => "http://#{/\w+/.gen}.#{/\w{3}/.gen}",
  :location => /\w+/.gen[0..49]
}}
#Need to find out if you don't need to do all this horrifying copypasting.
Researcher.fix(:commercial_account) {{
  :user_name            => unique {/\w+/.gen},
  :email   => unique {"#{/\w+/.gen}@#{/\w{10}/.gen}.#{/\w{3}/.gen}"},
  :role => "Commercial Account",
  :join_date => Time.now-(rand(100)+100).days,
  :last_login => Time.now-rand(100).days,
  :last_access => Time.now-rand(100).days,
  :info => /[:sentence:]/.gen[0..500],
  :website_url => "http://#{/\w+/.gen}.#{/\w{3}/.gen}",
  :location => /\w+/.gen[0..49]
}}
Researcher.fix(:admin) {{
  :user_name            => unique {/\w+/.gen},
  :email   => unique {"#{/\w+/.gen}@#{/\w{10}/.gen}.#{/\w{3}/.gen}"},
  :role => "Admin",
  :join_date => Time.now-(rand(100)+100).days,
  :last_login => Time.now-rand(100).days,
  :last_access => Time.now-rand(100).days,
  :info => /[:sentence:]/.gen[0..500],
  :website_url => "http://#{/\w+/.gen}.#{/\w{3}/.gen}",
  :location => /\w+/.gen[0..49]
}}
Researcher.fix(:user) {{
  :user_name            => unique {/\w+/.gen},
  :email   => unique {"#{/\w+/.gen}@#{/\w{10}/.gen}.#{/\w{3}/.gen}"},
  :role => "User",
  :join_date => Time.now-(rand(100)+100).days,
  :last_login => Time.now-rand(100).days,
  :last_access => Time.now-rand(100).days,
  :info => /[:sentence:]/.gen[0..500],
  :website_url => "http://#{/\w+/.gen}.#{/\w{3}/.gen}",
  :location => /\w+/.gen[0..49]
}}