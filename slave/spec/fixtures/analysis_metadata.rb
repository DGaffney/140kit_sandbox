AnalysisMetadata.fix{{
  :finished => [true,false][rand(2)],
  :rest => [true,false][rand(2)],
  :curation_id => Curation.pick.id,
  :analytical_offering_id => AnalyticalOffering.all.shuffle.first.id
}}
AnalysisMetadata.fix(:in_progress){{
  :finished => false,
  :rest => [true,false][rand(2)],
  :curation_id => Curation.pick.id,
  :analytical_offering_id => AnalyticalOffering.all.shuffle.first.id
}}