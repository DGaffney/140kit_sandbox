class SemanticAnalyzer < AnalysisMetadata
  require 'semantic'
  def self.run(analysis_metadata_id, percentile, analysis_type)
    analysis_type = analysis_type.upcase.to_sym
    @analysis_metadata = AnalysisMetadata.first(:id => analysis_metadata_id)
    curation = @analysis_metadata.curation
    conditional = Analysis.curation_conditional(curation)
    graph = Graph.first_or_create(:title => "semantic_results", :style => "table", :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id)
    offset = 0
    limit = 1000
    tweets = Tweet.all({:limit => limit, :offset => offset}.merge(conditional))
    corpus << []
    while !tweets.empty?
      tweets.each do |tweet|
        corpus << tweet.text
      end
      offset += limit
      tweets = Tweet.all({:limit => limit, :offset => offset}.merge(conditional))
    end
    terms = corpus.join(" ").split(" ").uniq
    search = Semantic::Search.new(corpus, :transforms => [analysis_type])
    semantic_set = []
    terms.each_pair do |term|
      semantic_set << {:label => term, :value => search.search([term]).sum}
    end
    semantic_set.sort!{|x,y| x[:value]<=>y[:value]}
    highest_matches = []
    if percentile.to_f == 0
      highest_matches = semantic_set
    else
      this_index = semantic_set.index(semantic_set.percentile(percentile.to_f))
      highest_matches = semantic_set[this_index..semantic_set.length-1]      
    end
    chunking = highest_matches.length > 1000 ? highest_matches.length/1000 : 1
    highest_matches.chunk(chunking).each do |chunk|
      GraphPoint.save_all(chunk.collect{|w| w.merge({:curation_id => curation.id, :analysis_metadata_id => @analysis_metadata.id, :graph_id => graph.id})})
    end
    return true
  end

end

