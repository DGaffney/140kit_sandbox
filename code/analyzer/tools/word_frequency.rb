# encoding: utf-8
class WordFrequency < AnalysisMetadata

  def self.run(analysis_metadata_id, percentile)
    @analysis_metadata = AnalysisMetadata.first(:id => analysis_metadata_id)
    curation = @analysis_metadata.curation
    conditional = Analysis.curation_conditional(curation)
    graph = Graph.first_or_create(:title => "word_frequencies", :style => "table", :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id)
    words = {}
    offset = 0
    limit = 1000
    tweets = Tweet.all({:limit => limit, :offset => offset}.merge(conditional))
    while !tweets.empty?
      tweets.each do |tweet|
        entities = Entity.all(:twitter_id => tweet.twitter_id, :dataset_id => tweet.dataset_id)
        entities_to_remove = entities.collect{|e| self.entity_value(e)}.compact.uniq
        text = tweet.text
        text.gsub(/#{entities_to_remove.join("|")}/, " ")
        text.split(self.useless_characters).each do |term|
          if term!=""
            words[term] = 0 if words[term].nil?
            words[term]+=1
          end
        end
      end
      offset += limit
      tweets = Tweet.all({:limit => limit, :offset => offset}.merge(conditional))
    end
    word_percentile = []
    words.each_pair do |k,v|
      word_percentile << {:label => k, :value => v}
    end
    word_percentile.sort!{|x,y| x[:value]<=>y[:value]}
    highest_words = []
    if percentile == 0
      highest_words = word_percentile
    else
      this_index = word_percentile.index(word_percentile.percentile(percentile.to_f))
      highest_words = word_percentile[this_index..word_percentile.length-1]      
    end
    chunking = highest_words.length > 1000 ? highest_words.length/1000 : 1
    highest_words.chunk(chunking).each do |chunk|
      GraphPoint.save_all(chunk.collect{|w| w.merge({:curation_id => curation.id, :analysis_metadata_id => @analysis_metadata.id, :graph_id => graph.id})})
    end
    return true
  end

  def self.useless_characters
    return Regexp.new(/\ |\,|\:|\.|\<|\>|\?|\/|\\|\+|\=|\_|\-|\(|\)|\*|\&|\^|\%|\#|\$|\[|\]|–|\n|\r|\t|\}|\{|\@|\!|¡|™|£|¢|∞|§|¶|•|ª|º|≠|‘|“|…|æ|÷|≥|≤|«|”|’|å|ß|∂|ƒ|©|˙|∆|˚|¬|Ω|≈|ç|√|∫|˜|µ|œ|∑|´|®|†|¥|¨|ˆ|ø|π"/)
  end

  def self.entity_value(e)
    if e.name == "screen_name"
      return "@"+e.value
    elsif e.name == "text"
      return "#"+e.value
    elsif e.name == "url"
      return e.value
    end
  end
end

