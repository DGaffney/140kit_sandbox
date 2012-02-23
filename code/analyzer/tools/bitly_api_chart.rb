class BitlyApiChart < AnalysisMetadata

  def self.run(curation_id, only_primary_links=true, bitly_account="dgaff")
    curation = Curation.get(curation_id)
    conditional = Analysis.curation_conditional(curation)
    limit = 1000
    offset = 0
    entities = []
    if only_primary_links==true
      screen_names = []
      conditional[:dataset_id].each do |dataset_id|
        dataset = Dataset.first(:id => dataset_id)
        screen_names << dataset.params.split(",").first if dataset.scrape_type == "audience_profile"
      end
      primary_user_ids = User.all(conditional.merge({:screen_name => screen_names, :fields => [:twitter_id], :unique => true})).collect{|x| x.twitter_id}
      twitter_ids = Tweet.all(conditional.merge({:user_id => primary_user_ids, :fields => [:twitter_id], :unique => true})).collect{|x| x.twitter_id}
      conditional = conditional.merge({:twitter_id => twitter_ids})
      entities = Entity.all(conditional.merge({:name => "url", :fields => [:value], :unique => true, :limit => limit, :offset => offset}))
    else
      entities = Entity.all(conditional.merge({:name => "url", :fields => [:value], :unique => true, :limit => limit, :offset => offset}))
    end
    bitly_credentials = YAML.load(File.open(DIR+'/config/bitly.yml').read)[bitly_account]
    bitly_data = lambda{|url| data = JSON.parse(open("http://api.bitly.com/v3/clicks?shortUrl=#{url.gsub(":", "%3A").gsub("/", "%2F")}&login=#{bitly_credentials["login"]}&apiKey=#{bitly_credentials["api_key"]}&format=json").read)["data"]["clicks"].first rescue nil; {:global => data["global_clicks"], :user => data["user_clicks"]} rescue {:user => 0, :global => 0}}
    graph_global = Graph.first_or_create(:title => "click_chart_#{only_primary_links == true ? "main" : "all"}_global", :curation_id => curation_id, :style => "histogram", :analysis_metadata_id => 0)
    graph_user = Graph.first_or_create(:title => "click_chart_#{only_primary_links == true ? "main" : "all"}_user", :curation_id => curation_id, :style => "histogram", :analysis_metadata_id => 0)
    graph_global.save!
    graph_user.save!
    GraphPoint.all(:graph_id => graph_global.id).destroy
    GraphPoint.all(:graph_id => graph_user.id).destroy
    graph_points = []
    while !entities.empty?
      entities.each do |entity|
        parsed_url = self.parse_url(entity.value)
        if parsed_url[:possible_bitly]
          click_results = bitly_data.call(entity.value)
          graph_points << {:label => entity.value, :value => click_results[:global], :graph_id => graph_global.id, :curation_id => curation_id, :analysis_metadata_id => 0}
          graph_points << {:label => entity.value, :value => click_results[:user], :graph_id => graph_user.id, :curation_id => curation_id, :analysis_metadata_id => 0}
        end
        if graph_points.length > 1000
          GraphPoint.save_all(graph_points)
          graph_points = []
        end
      end
      offset += limit
      entities = Entity.all(conditional.merge({:name => "url", :fields => [:value], :unique => true, :limit => limit, :offset => offset}))
    end
    GraphPoint.save_all(graph_points)
    graph_points = []
    graph_global.written = true
    graph_global.save!
    graph_user.written = true
    graph_user.save!
  end
  
  def self.parse_url(url)
    not_bitly_domains = ["t.co"]
    domain = url.gsub("http://", "").split("/").first
    path = url.gsub("http://", "").gsub(domain, "").gsub("/", "")
    possible_bitly = url.count("/") == 3 && !not_bitly_domains.include?(domain)
    return {:domain => domain, :path => path, :possible_bitly => possible_bitly}
  end
end