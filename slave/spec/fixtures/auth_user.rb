AuthUser.fix{{
  :user_name => User.pick.screen_name,
  :password => /\w+/.gen[5..25]
}}
AuthUser.fix(:in_use){{
  :user_name => User.pick.screen_name,
  :password => /\w+/.gen[5..25],
  :instance_id => Digest::SHA1.hexdigest("#{/\w+/.gen[5..25]}")
}}
