GraphPoint.fix{{
  :label => /\w+/.gen[5..25],
  :label => rand*rand(100),
  :graph_id => Graph.pick.id,
  :curation_id => Curation.pick.id,
}}