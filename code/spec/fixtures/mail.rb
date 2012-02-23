Mail.fix{{
  :sent => [true,false][rand(2)],
  :message_content => /[:sentence:]/.gen[20..2000],
  :researcher_id => researcher = Researcher.pick,
  :subject => /[:sentence:]/.gen[20..200],
  :recipient => researcher.email
}}