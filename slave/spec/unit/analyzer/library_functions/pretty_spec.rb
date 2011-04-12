describe Pretty do
  DEFAULT_TRIALS=100
  before :all do
    researcher = Researcher.gen
    researcher.save!
    curation = Curation.gen
    curation.save!
    analytical_offering = AnalyticalOffering.gen
    analytical_offering.save!
    analysis_metadata = AnalysisMetadata.gen
    analysis_metadata.save!
  end
  
  before :each do
    GraphPoint.destroy
    DataMapper::Sweatshop::UniqueWorker.unique_map.clear
  end
  
  it "should pretty_up_labels correctly for tweets_location" do
    graph = Graph.gen
    graph.title = "tweets_location"
    graph.save!
    graph_points = []
    1.upto(DEFAULT_TRIALS) do |graph_point|
      begin
        graph_point = GraphPoint.gen(:tweets_location)
        graph_point.save!
        graph_points << graph_point.attributes
      rescue
        retry
      end
    end
    results = Pretty.pretty_up_labels(graph, graph_points)
    results.class.should == Array
    results.first.class.should == Hash
    results.length.should <= DEFAULT_TRIALS
  end

  it "should pretty_up_labels correctly for tweets_language" do
    graph = Graph.gen
    graph.title = "tweets_language"
    graph.save!
    graph_points = []
    1.upto(Pretty.language_map.keys.length) do |graph_point|
      begin
        graph_point = GraphPoint.gen(:tweets_language)
        graph_point.save!
        graph_points << graph_point.attributes
      rescue
        retry
      end
    end
    results = Pretty.pretty_up_labels(graph, graph_points)
    results.class.should == Array
    results.first.class.should == Hash
    results.length.should <= Pretty.language_map.keys.length
  end

  it "should pretty_up_labels correctly for tweets_created_at" do
    graph = Graph.gen
    graph.title = "tweets_created_at"
    graph.save!
    graph_points = []
    1.upto(100) do |graph_point|
      begin
        graph_point = GraphPoint.gen(:tweets_created_at)
        graph_point.save!
        graph_points << graph_point.attributes
      rescue
        retry
      end
    end
    graph_points.collect{|x| x[:label] = Time.parse(x[:label])}
    results = Pretty.pretty_up_labels(graph, graph_points)
    results.class.should == Array
    results.first.class.should == Hash
    results.length.should <= DEFAULT_TRIALS
  end

  it "should pretty_up_labels correctly for tweets_source" do
    graph = Graph.gen
    graph.title = "tweets_source"
    graph.save!
    graph_points = []
    1.upto(DEFAULT_TRIALS) do |graph_point|
      begin
        graph_point = GraphPoint.gen(:tweets_source)
        graph_point.save!
        graph_points << graph_point.attributes
      rescue
        retry
      end
    end
    results = Pretty.pretty_up_labels(graph, graph_points)
    results.class.should == Array
    results.first.class.should == Hash
    results.length.should <= DEFAULT_TRIALS
  end

  it "should pretty_up_labels correctly for users_lang" do
    graph = Graph.gen
    graph.title = "users_lang"
    graph.save!
    graph_points = []
    1.upto(Pretty.language_map.keys.length) do |graph_point|
      begin
        graph_point = GraphPoint.gen(:users_lang)
        graph_point.save!
        graph_points << graph_point.attributes
      rescue
        retry
      end
    end
    results = Pretty.pretty_up_labels(graph, graph_points)
    results.class.should == Array
    results.first.class.should == Hash
    results.length.should <= Pretty.language_map.keys.length
  end

  it "should pretty_up_labels correctly for users_created_at" do
    graph = Graph.gen
    graph.title = "users_created_at"
    graph.save!
    graph_points = []
    1.upto(DEFAULT_TRIALS) do |graph_point|
      begin
        graph_point = GraphPoint.gen(:users_created_at)
        graph_point.save!
        graph_points << graph_point.attributes
      rescue
        retry
      end
    end
    graph_points.collect{|x| x[:label] = Time.parse(x[:label])}
    results = Pretty.pretty_up_labels(graph, graph_points)
    results.class.should == Array
    results.first.class.should == Hash
    results.length.should <= DEFAULT_TRIALS
  end
end