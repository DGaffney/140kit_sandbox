# DataMapper::Inflector.pluralization_rules.last.merge!(
#   {"entity" => "entities", "analysis_metadatum" => "analysis_metadata"}
# )
DataMapper::Inflector.inflections do |inflect|
  inflect.irregular "entity", "entities" 
  inflect.irregular "analysis_metadatum", "analysis_metadata"
end