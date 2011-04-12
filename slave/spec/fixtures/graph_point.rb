GraphPoint.fix{{
  :label => /\w+/.gen[5..25],
  :value => rand(100),
  :graph_id => (graph=Graph.pick).id,
  :curation_id => Curation.pick.id,
  :analysis_metadata_id => graph.analysis_metadata_id
}}
GraphPoint.fix(:tweets_location){{
  :label => unique { ["\303\234T:", "UT:", "iPhone:", "Pre:", nil, "#{/\w+/.gen[5..25]}"][rand(6)]},
  :value => rand(100),
  :graph_id => (graph=Graph.pick).id,
  :curation_id => Curation.pick.id,
  :analysis_metadata_id => graph.analysis_metadata_id
}}
GraphPoint.fix(:tweets_language){{
  :label => unique { ["en","ja","it","de","fr","kr","es"][rand(7)]},
  :value => rand(100),
  :graph_id => (graph=Graph.pick).id,
  :curation_id => Curation.pick.id,
  :analysis_metadata_id => graph.analysis_metadata_id
}}
GraphPoint.fix(:tweets_created_at){{
  :label => unique { Time.now-(rand(100)+1).days+rand(86400)},
  :value => rand(100),
  :graph_id => (graph=Graph.pick).id,
  :curation_id => Curation.pick.id,
  :analysis_metadata_id => graph.analysis_metadata_id
}}
GraphPoint.fix(:tweets_source){{
  :label => unique { "<a href=\"#{"http://#{/\w+/.gen}.#{/\w{3}/.gen}"}\">#{/\w+/.gen[5..25]}</a>"},
  :value => rand(100),
  :graph_id => (graph=Graph.pick).id,
  :curation_id => Curation.pick.id,
  :analysis_metadata_id => graph.analysis_metadata_id
}}
GraphPoint.fix(:users_lang){{
  :label => unique { ["en","ja","it","de","fr","kr","es"][rand(7)]},
  :value => rand(100),
  :graph_id => (graph=Graph.pick).id,
  :curation_id => Curation.pick.id,
  :analysis_metadata_id => graph.analysis_metadata_id
}}
GraphPoint.fix(:users_created_at){{
  :label => unique { Time.now-(rand(100)+1).days+rand(86400)},
  :value => rand(100),
  :graph_id => (graph=Graph.pick).id,
  :curation_id => Curation.pick.id,
  :analysis_metadata_id => graph.analysis_metadata_id
}}