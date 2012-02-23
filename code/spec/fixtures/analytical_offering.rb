AnalyticalOffering.fix{{
  :title => /\w+/.gen[5..25],
  :description => /[:sentence:]/.gen[50..250],  
  :function => /\w+/.gen[5..25],
  :rest => [true,false][rand(2)],
  :created_by => "#{/\w+/.gen[5..25]} #{/\w+/.gen[5..25]}",
  :created_by_link => "http://#{/\w+/.gen}.#{/\w{3}/.gen}",
  :enabled => [true,false][rand(2)],
  :language => ["ruby","c","python","java","r","php"][rand(6)],
  :access_level => ["Admin","Commercial Account","Researcher","User"][rand(4)],
  :source_code_link => "http://#{/\w+/.gen}.#{/\w{3}/.gen}"
}}