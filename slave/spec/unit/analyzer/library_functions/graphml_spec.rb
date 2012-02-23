describe Graphml do
  it "should generate header" do
    Graphml::header("Test").class.should == String
  end
  
  it "should generate attribute_declarations" do
    attribute_declarations = [
      {:id => "style", :for => "edge", :attr_name => "style", :attr_type => "string"},
      {:id => "weight", :for => "edge", :attr_name => "weight", :attr_type => "float"},
      {:id => "screen_name", :for => "node", :attr_name => "screen_name", :attr_type => "string"},
      {:id => "followers_count", :for => "node", :attr_name => "followers_count", :attr_type => "int"}
    ]
    Graphml::attribute_declarations(attribute_declarations).class.should == Array
  end
  
  it "should generate attribute_declaration" do
    attribute_declaration = {:id => "screen_name", :title => "screen_name", :type => "string"}  
    Graphml::attribute_declaration(attribute_declaration).class.should == String
  end
  
  it "should generate footer" do
    Graphml::footer.class.should == String
  end
  
  it "should generate nodes" do
    nodes = [{ :id => "dgaff", 
      :label => "dgaff", 
      :attributes => [
        { :for => "size", 
          :value => 1, 
          :start => 1, 
          :end => 2
        }, 
        { :for => "size", 
          :value => 2, 
          :start => 2, 
          :end => 3
        },
        { :for => "followers_count", 
          :value => 200, 
        }
      ], 
      :slices => [
        { :start => 1, 
          :end => 2
        }, 
        { :start => 2, 
          :end => 3
        }
      ]
    },
    { :id => "peeinears", 
      :label => "peeinears"
    }]
    Graphml::nodes(nodes).class.should == Array
  end
  
  it "should generate node" do
    node = { :id => "dgaff", 
      :label => "dgaff", 
      :attributes => [
        { :for => "size", 
          :value => 1, 
          :start => 1, 
          :end => 2
        }, 
        { :for => "size", 
          :value => 2, 
          :start => 2, 
          :end => 3
        },
        { :for => "followers_count", 
          :value => 200, 
        }
      ], 
      :slices => [
        { :start => 1, 
          :end => 2
        }, 
        { :start => 2, 
          :end => 3
        }
      ]
    }
    Graphml::node(node).class.should == String
  end

  it "should generate edges" do
    edges = [
      { :source => "dgaff", 
        :target => "peeinears", 
        :start => 1, 
        :end => 2, 
        :weight => 2, 
        :attributes => [
        { :for => "size", 
          :value => 1, 
          :start => 1, 
          :end => 2
        }, 
        { :for => "size", 
          :value => 2, 
          :start => 2, 
          :end => 3
        },
        { :for => "followers_count", 
          :value => 200, 
        }
      ], 
      :slices => [
        { :start => 1, 
          :end => 2
        }, 
        { :start => 2, 
          :end => 3
        }
      ]
    },
    { :source => "dgaff", 
      :target => "peeinears", 
      :start => 1, 
      :end => 2, 
      :weight => 2, 
    }]
    Graphml::edges(edges).class.should == Array
  end
  
  it "should generate edge" do
    edge = { :source => "dgaff", 
        :target => "peeinears", 
        :start => 1, 
        :end => 2, 
        :weight => 2, 
        :attributes => [
        { :for => "size", 
          :value => 1, 
          :start => 1, 
          :end => 2
        }, 
        { :for => "size", 
          :value => 2, 
          :start => 2, 
          :end => 3
        },
        { :for => "followers_count", 
          :value => 200, 
        }
      ], 
      :slices => [
        { :start => 1, 
          :end => 2
        }, 
        { :start => 2, 
          :end => 3
        }
      ]
    }
    Graphml::edge(edge).class.should == String
  end

  it "should generate attribute" do
    attribute = {:for => "weight", :value => 2, :start => 1, :end => 2}
    Graphml::attribute(attribute).class.should == String
  end
  
  it "should generate graphml_class" do
    Graphml::CLASSES.each_pair do |k, v|
      Graphml::graphml_class(k).should==v
    end
  end
  
  describe Graphml::Writer do
    it "should initialize_temp_data" do
      tweets = []
      entities = []
      users = []
      friendships = []
      dataset = Dataset.gen
      1.upto(10) do |gen_sample|
        user = User.gen
        user.dataset_id = dataset.id
        user.save
        users << user
        tweet = Tweet.gen
        tweet.dataset_id = dataset.id
        tweet.save
        tweets << tweet
        entity = Entity.gen
        entity.dataset_id = dataset.id
        entity.save
        entities << entity
        friendship = Friendship.gen
        friendship.dataset_id = dataset.id
        friendship.save
        friendships << friendship
      end
      curation = Curation.gen
      curation.datasets << dataset
      dataset.save
      curation.save
      am = AnalysisMetadata.gen
      am.curation_id = curation.id
      am.save!
      fs = {:conditional => {}, :analysis_metadata_id => am.id, :style => "network_graph", :title => "conversational_tweets_entity_based", :dynamic => true, :formats => ["gexf", "graphml"], :node_attributes => [], :edge_attributes => [:style], :generate_graph_points => true, :override_conditional => false}
      graph = Graph.new(:title => fs[:title], :style => fs[:style], :curation_id => curation.id, :analysis_metadata_id => am.id)
      graph.save!
      Sh::mkdir(ENV['TMP_PATH'])
      Graphml::Writer.initialize_temp_data(fs, graph)
      Sh::sh("ls #{ENV['TMP_PATH']}").split("\n").include?("temp_header.graphml").should == true
    end
    
    it "should generate_temp_data" do
      tweets = []
      entities = []
      users = []
      friendships = []
      dataset = Dataset.gen
      1.upto(10) do |gen_sample|
        user = User.gen
        user.dataset_id = dataset.id
        user.save
        users << user
        tweet = Tweet.gen
        tweet.dataset_id = dataset.id
        tweet.save
        tweets << tweet
        entity = Entity.gen
        entity.dataset_id = dataset.id
        entity.save
        entities << entity
        friendship = Friendship.gen
        friendship.dataset_id = dataset.id
        friendship.save
        friendships << friendship
      end
      curation = Curation.gen
      curation.datasets << dataset
      dataset.save
      curation.save
      am = AnalysisMetadata.gen
      am.analytical_offering_id = AnalyticalOffering.first(:function => "network_grapher").id
      am.curation_id = curation.id
      am.save!
      fs = {:conditional => {}, :analysis_metadata_id => am.id, :style => "network_graph", :title => "conversational_tweets_entity_based", :dynamic => true, :formats => ["gexf", "graphml"], :node_attributes => [], :edge_attributes => [:style], :generate_graph_points => true, :override_conditional => false}
      graph = Graph.new(:title => fs[:title], :style => fs[:style], :curation_id => curation.id, :analysis_metadata_id => am.id)
      graph.save!
      edges = []
      tweets.each do |tweet|
        edge = Edge.create(:start_node => User.all.shuffle.first, :end_node => tweet.screen_name, :edge_id => tweet.twitter_id, :analysis_metadata_id => am.id, :graph_id => graph.id, :curation_id => curation.id, :style => EdgeGenerator.derive_style_from_tweet(tweet))
        edges << edge
      end
      Sh::mkdir(ENV['TMP_PATH'])
      Graphml::Writer.generate_temp_data(fs, edges)
      Sh::sh("ls #{ENV['TMP_PATH']}").split("\n").include?("temp_node.graphml").should == true
      Sh::sh("ls #{ENV['TMP_PATH']}").split("\n").include?("temp_edge.graphml").should == true
    end
    
    it "should finalize_temp_data" do
      tweets = []
      entities = []
      users = []
      friendships = []
      dataset = Dataset.gen
      1.upto(10) do |gen_sample|
        user = User.gen
        user.dataset_id = dataset.id
        user.save
        users << user
        tweet = Tweet.gen
        tweet.dataset_id = dataset.id
        tweet.save
        tweets << tweet
        entity = Entity.gen
        entity.dataset_id = dataset.id
        entity.save
        entities << entity
        friendship = Friendship.gen
        friendship.dataset_id = dataset.id
        friendship.save
        friendships << friendship
      end
      curation = Curation.gen
      curation.datasets << dataset
      dataset.save
      curation.save
      am = AnalysisMetadata.gen
      am.analytical_offering_id = AnalyticalOffering.first(:function => "network_grapher").id
      am.curation_id = curation.id
      am.save!
      fs = {:conditional => {}, :analysis_metadata_id => am.id, :style => "network_graph", :title => "conversational_tweets_entity_based", :dynamic => true, :formats => ["gexf", "graphml"], :node_attributes => [], :edge_attributes => [:style], :generate_graph_points => true, :override_conditional => false}
      Graphml::Writer.finalize_temp_data(fs).class.should == Fixnum
    end
  end
end