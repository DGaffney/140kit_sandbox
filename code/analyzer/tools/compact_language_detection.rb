class CompactLanguageDetection < AnalysisMetadata
  def self.run(analysis_metadata_id)
    @analysis_metadata = AnalysisMetadata.first(:id => analysis_metadata_id)
    curation = @analysis_metadata.curation
    conditional = Analysis.curation_conditional(curation)
    graph = Graph.first_or_create(:title => "cld_value_overview", :style => "table", :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id)
    offset = 0
    limit = 20000
    tweets = Tweet.all({:limit => limit, :offset => offset, :fields => [:twitter_id, :text]}.merge(conditional))
    language_set = {}
    while !tweets.empty?
      tweets.each do |tweet|
        language = self.detect_language_name(tweet.text)
        if language_set[language].nil?
          language_set[language] = 1
        else
          language_set[language] += 1
        end
      end
      offset += limit
      tweets = Tweet.all({:limit => limit, :offset => offset, :fields => [:twitter_id, :text]}.merge(conditional))
    end
    values = []
    language_set.each_pair do |language, count|
      values << {:graph_id => graph.id, :label => language, :value => count, :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id}
    end
    GraphPoint.save_all(values)
    return true
  end
  
  def self.detect_language_name(data)
    value = CLD.detect_language(data)[:name]
    value = "unknown" if value == "TG_UNKNOWN_LANGUAGE"
    return value.split("_").collect(&:capitalize).join(" ")
  end
end

