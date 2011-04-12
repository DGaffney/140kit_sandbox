AnalysisMetadata.fix{{
  :finished => [true,false][rand(2)],
  :rest => [true,false][rand(2)],
  :curation_id => Curation.pick.id,
  :analytical_offering_id => AnalyticalOffering.pick.id
}}
AnalysisMetadata.fix(:in_progress){{
  :finished => false,
  :rest => [true,false][rand(2)],
  :curation_id => Curation.pick.id,
  :analytical_offering_id => AnalyticalOffering.pick.id
}}