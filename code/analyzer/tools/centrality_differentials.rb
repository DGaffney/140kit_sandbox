# encoding: utf-8
class CentralityDifferentials < AnalysisMetadata
  
  def self.run(curation_id, step_size=3600, include_phrases=true)
    puts "starting..."
    curation = Curation.first(:id => curation_id)
    conditional = Analysis.curation_conditional(curation)
    first_tweet_time = Tweet.first(conditional.merge(:order => [:created_at.asc])).created_at
    last_tweet_time = Tweet.first(conditional.merge(:order => [:created_at.desc])).created_at
    graphs = []
    graph_groupings = []
    latest_grouping = []
    (first_tweet_time..last_tweet_time).step(step_size) do |time|
      puts "running for time #{time}"
      tweet_count = Tweet.count(conditional.merge(:created_at.gte => time, :created_at.lte => time+3600))
      if tweet_count != 0
        graph = Graph.new
        graph.year = time.year
        graph.month = time.month
        graph.date = time.day
        graph.hour = time.hour
        graph.style = "multivariate_network"
        graph.title = "#{curation_id}_#{time.year}_#{time.month}_#{time.day}_#{time.hour}_#{step_size}_phrase"
        graph.time_slice = time
        graph.curation_id = curation_id
        graph.analysis_metadata_id = 0
        graph.save!
        self.create_edges(time, step_size, conditional, curation, graph, include_phrases)
        self.generate_centralities_from_python_script(time, step_size, graph)
        graphs << graph
        latest_grouping << graph
        if latest_grouping.length==2
          graph_groupings << latest_grouping
          latest_grouping = []
        end
      end
    end
    graph_groupings.each do |grouping|
      puts "running grouping #{graph_groupings.index(grouping)}/#{graph_groupings.length-1}"
      first = grouping[0]
      last = grouping[1]
      graph = Graph.new
      graph.year = last.year
      graph.month = last.month
      graph.date = last.date
      graph.hour = last.hour
      graph.style = "multivariate_network_differential"
      graph.title = "#{curation_id}_#{first.year}_#{first.month}_#{first.date}_#{first.hour}_#{step_size}_#{first.id}_#{last.id}"
      graph.time_slice = last.time_slice
      graph.curation_id = curation_id
      graph.analysis_metadata_id = 0
      graph.save!
      self.determine_node_differentials(first, last, graph)
    end
  end
  
  def self.determine_node_differentials(first, last, graph, limit=1000)
    offset = 0
    edges = Edge.all(:graph_id => last.id, :limit => limit, :offset => offset)
    new_edges = []
    while !edges.empty?
      edges.each do |edge|
        new_edge = {}
        new_edge = edge.attributes
        new_edge.delete(:id)
        first_start_centrality = (Edge.first({:start_node => edge.start_node, :start_node_kind => edge.start_node_kind, :graph_id => first.id}).start_centrality rescue Edge.first({:end_node => edge.start_node, :end_node_kind => edge.start_node_kind, :graph_id => first.id}).end_centrality rescue 0) || 0
        new_edge[:start_centrality] =  Math.log(edge.start_centrality)-Math.log(first_start_centrality)
        first_end_centrality = (Edge.first({:start_node => edge.end_node, :start_node_kind => edge.end_node_kind, :graph_id => first.id}).start_centrality rescue Edge.first({:end_node => edge.end_node, :end_node_kind => edge.end_node_kind, :graph_id => first.id}).end_centrality rescue 0) || 0
        new_edge[:end_centrality] =  Math.log(edge.end_centrality)-Math.log(first_end_centrality)
        new_edge[:graph_id] = graph.id
        new_edges << new_edge
      end
      if new_edges.length > limit
        Edge.save_all(new_edges)
        new_edges = []
      end
      offset += limit
      edges = Edge.all(:graph_id => last.id, :limit => limit, :offset => offset)
    end
    Edge.save_all(new_edges)
    new_edges = []
  end
  
  def self.create_edges(time, step_size, conditional, curation, graph, include_phrases, limit=1000)
    offset = 0
    tweets = Tweet.all(conditional.merge(:created_at.gte => time, :created_at.lte => time+3600, :limit => limit, :offset => offset))
    edges = []
    curation_id = curation.id
    while !tweets.empty?
      tweets.each do |tweet|
        words = self.split_tweet(tweet)
        if include_phrases
          edges += self.edges_with_phrases(tweet, graph, curation, words)
        else
          edges += self.edges_without_phrases(tweet, graph, curation, words)
        end
        if edges.length > limit
          Edge.save_all(edges)
          edges = []
        end
      end
      Edge.save_all(edges)
      edges = []
      offset+=limit
      tweets = Tweet.all(conditional.merge(:created_at.gte => time, :created_at.lte => time+3600, :limit => limit, :offset => offset))
    end
  end
  
  def self.edges_with_phrases(tweet, graph, curation, words, phrase_length=4)
    edges = []
    new_words = []
    phrase_sections = []
    stop_words = File.open(DIR+"/analyzer/resources/stop_words.txt").read.split("\n")
    current_phrase = []
    words.each do |word|
      if word[:kind]!="term"
        edge = {}
        edge[:start_node] = tweet.screen_name
        edge[:start_node_kind] = "screen_name"
        edge[:end_node] = word[:term]
        edge[:graph_id] = graph.id
        edge[:curation_id] = curation.id
        edge[:time] = tweet.created_at
        edge[:start_centrality] = 0.0
        edge[:end_centrality] = 0.0
        edge[:start_degree] = 0
        edge[:end_degree] = 0
        edge[:analysis_metadata_id] = 0
        edge[:style] = "multivariate"
        edge[:end_node_kind] = word[:kind]
        edges << edge
        phrase_sections << current_phrase if !current_phrase.empty?
      else
        current_phrase << word
      end
    end
    combinations = []
    1.upto(16) do |count|
      combo = [count[0] == 1, count[1] == 1, count[2] == 1, count[3] == 1].reverse
      combinations << combo if combo.last
    end
    phrase_sections << current_phrase if !current_phrase.empty?
    phrase_sections.uniq!
    phrase_sections.each do |phrase_section|
      phrase_section.each do |word|
        length = phrase_section.index(word)+phrase_length-1 < phrase_section.length-1 ? phrase_section.index(word)+phrase_length-1 : phrase_section.length-1
        this_phrase = phrase_section[phrase_section.index(word)..length]
        this_phrase.collect{|p| p[:term]}.all_combinations(1..phrase_length).each do |phrase|
          phrase = phrase.collect{|p| this_phrase.select{|pp| pp[:term] == p}.first}
          phrase_combination = phrase.collect{|w| !stop_words.include?(w[:term])}
          if (phrase_combination.uniq.length == 1 && phrase_combination.first == true) || (phrase_combination.uniq.length == 2 && combinations.include?(phrase_combination))
            actual_phrase = phrase.collect{|x| x[:term]}.join(" ")
            edge = {}
            edge[:start_node] = tweet.screen_name
            edge[:start_node_kind] = "screen_name"
            edge[:end_node] = actual_phrase
            edge[:graph_id] = graph.id
            edge[:curation_id] = curation.id
            edge[:time] = tweet.created_at
            edge[:start_centrality] = 0.0
            edge[:end_centrality] = 0.0
            edge[:start_degree] = 0
            edge[:end_degree] = 0
  	        edge[:analysis_metadata_id] = 0
            edge[:style] = "multivariate"
            edge[:end_node_kind] = phrase.length == 1 ? "term" : "phrase"
            edges << edge
          end
        end    
      end
    end
    return edges.uniq
  end

  def self.edges_without_phrases(tweet, graph, curation, words)
    edges = []
    words.each do |node|
      edge = {}
      edge[:start_node] = tweet.screen_name
      edge[:start_node_kind] = "screen_name"
      edge[:end_node] = node[:term]
      edge[:end_node_kind] = node[:kind]
      edge[:graph_id] = graph.id
      edge[:curation_id] = curation.id
      edge[:time] = tweet.created_at
      edge[:start_centrality] = 0.0
      edge[:end_centrality] = 0.0
      edge[:start_degree] = 0
      edge[:end_degree] = 0
      edge[:analysis_metadata_id] = 0
      edge[:style] = "multivariate"
      edges << edge
    end
    return edges
  end

  def self.generate_centralities_from_python_script(time, step_size, graph, limit=1000)
    env = ENV["e"] || "development"
    database = YAML.load(File.open(DIR+'/config/database.yml').read)
    Sh::mkdir(ENV['TMP_PATH'])
    `python #{DIR}/analyzer/resources/python/pagerank.py #{graph.id} #{ENV['TMP_PATH']}/results.csv #{database[env]["hostname"]} #{database[env]["username"]} #{database[env]["password"]} #{database[env]["database"]} #{database[env]["port"]}`
    edges = []
    FasterCSV.open("#{ENV['TMP_PATH']}/results.csv", "r").each do |row|
      edges << {:id => row[0], :start_node => Iconv.iconv('utf-8', 'ISO_8859-1', row[1]), :end_node => Iconv.iconv('utf-8', 'ISO_8859-1', row[2]), :time => Time.parse(row[3]), :edge_id => row[4], :flagged => row[5], :style => row[6], :start_node_kind => row[7], :end_node_kind => row[8], :analysis_metadata_id => row[9], :curation_id => row[10], :graph_id => row[11], :start_centrality => row[12], :end_centrality => row[13], :start_degree => row[14], :end_degree => row[15]}    	
      if edges.length > limit
        Edge.update_all(edges)
        edges = []
      end
    end
    Edge.update_all(edges)
    edges = []
  end

  def self.split_tweet(tweet)
    cleaned_terms = []
    entities = tweet.class == Tweet ? tweet.entities : Entity.all(:twitter_id => tweet.twitter_id, :dataset_id => tweet.dataset_id)
    tweet.text.split(/\\n| |\\r|\\t/).select{|elem| !elem.empty?}.each do |term|
      puts term.inspect
      valid_term = false
      while !valid_term
        if entities.collect{|et| et.value }.include?(term)
          cleaned_terms << {:term => term, :kind => entities.collect{|et| et.name if et.value == term}.compact.uniq.first}
          valid_term = true
        else
          clean_term = self.clean_term(term)
          valid_term = clean_term==term||clean_term.nil?
          term = clean_term
          if !clean_term.empty? && clean_term != "&"
            cleaned_terms << {:term => term, :kind => "term", :dataset_id => tweet.dataset_id} if !term.nil? if valid_term
          end
        end
      end
    end
    return cleaned_terms
  end

  def self.clean_term(term)
    if term.length == 1
      return term if self.useful_single_letter?(term)
    else
      if !self.useful_single_letter?(term.split("").first)
        return term.split("")[1..term.length-1].join
      elsif !self.useful_single_letter?(term.split("").last)
        return term.split("")[0..term.length-2].join
      else return term
      end
    end
  end

  def self.useful_single_letter?(term)
    return ![",", ":", ".", "<", ">", "?", "/", "\\", "+", "=", "_", "-", "(", ")", "*", "&", "^", "%", "#", "\$", 
      "\{", "@", "!", "¡", "™", "£", "¢", "∞", "§", "¶", "•", "ª", "º", "–", "≠", "‘", "“", "…", "æ", "[", "]",
      "÷", "≥", "≤", "«", "|", "”", "’", "}", "å", "ß", "∂", "ƒ", "©", "˙", "∆", "˚", "¬", "Ω", "≈", 
      "ç", "√", "∫", "˜", "µ", "œ", "∑", "´", "®", "†", "¥", "¨", "ˆ", "ø", "π", "\n", "\r", "\t", "\\n", "\\r", "\\t"].include?(term)
  end

  def self.generate_nodes(tweet, extra_conditions={})
    return self.split_tweet(tweet, extra_conditions).flatten.uniq
  end

  def self.generate_edges(tweet, tweet_nodes, edges, extra_conditions={})
    tweet_nodes.each do |tweet_node_start|
      tweet_nodes.each do |tweet_node_end|
        if tweet_node_start!=tweet_node_end
          edge_attributes = {:dataset_id => tweet.dataset_id, :start_term_node => tweet_node_start[:term], :start_term_kind => tweet_node_start[:kind], :end_term_node => tweet_node_end[:term], :end_term_kind => tweet_node_end[:kind]}
          edge = self.find_existing_edge(edge_attributes, edges)
          this_closeness=self.calculate_closeness(tweet_node_start[:term], tweet_node_end[:term], tweet_nodes)
          non_empty_edge = !tweet_node_start[:term].empty? && !tweet_node_end[:term].empty? && tweet_node_start[:term] != "&" && tweet_node_end[:term] != "&"
          if edge
            edge[:start_term_kind] = tweet_node_start[:kind]
            edge[:end_term_kind] = tweet_node_end[:kind]
            if non_empty_edge
              edges << edge if edge[:id]
            end
          else
            if non_empty_edge
              edges[:new] << edge_attributes.merge({:closeness => this_closeness, :occurrences => 1, :start_term_kind => tweet_node_start[:kind], :end_term_kind => tweet_node_end[:kind]})
            end
          end
        end
      end
    end
    return edges
  end  
end