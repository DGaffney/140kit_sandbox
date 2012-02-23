Whitelisting.fix{{
  :hostname => /\w+/.gen[5..40],
  :ip => "#{rand(256)}.#{rand(256)}.#{rand(256)}.#{rand(256)}",
  :whitelisted => [true,false][rand(2)]
}}