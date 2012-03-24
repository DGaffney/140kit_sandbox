class EntityMap < AnalysisMetadata
  
  def self.run(analysis_metadata_id, entities_included)
    @analysis_metadata = AnalysisMetadata.first(:id => analysis_metadata_id)
    curation = Curation.first(:curation_id => @analysis_metadata.curation_id)
    conditional = Analysis.curation_conditional(curation)
    entity_names = []
    case entities_included
    when "hashtag"
      entity_names << "hashtag"
    when "mention"
      entity_names << "mention"
    when "url"
      entity_names << "url"
    when "hashtag_mention"
      entity_names << "hashtag"
      entity_names << "mention"
    when "hashtag_url"
      entity_names << "hashtag"
      entity_names << "url"
    when "mention_url"
      entity_names << "mention"
      entity_names << "url"
    when "hashtag_mention_url"
      entity_names << "hashtag"
      entity_names << "mention"
      entity_names << "url"
    end
    entities = Entity.all({:name => entities_included}.merge(conditional))
  end
end

#entities_included: ["hashtag", "mention", "url", "hashtag_mention", "hashtag_url", "mention_url", "hashtag_mention_url"]