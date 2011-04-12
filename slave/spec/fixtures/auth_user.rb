AuthUser.fix{{
  :screen_name => unique{"#{/\w+/.gen[5..25]}"},
  :password => /\w+/.gen[5..25]
}}
AuthUser.fix(:in_use){{
  :screen_name => unique{"#{/\w+/.gen[5..25]}"},
  :password => /\w+/.gen[5..25],
  :instance_id => Digest::SHA1.hexdigest("#{/\w+/.gen[5..25]}")
}}
