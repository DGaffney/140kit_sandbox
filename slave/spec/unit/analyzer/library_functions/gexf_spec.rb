describe Gexf do
  it "should generate header" do
    Gexf::header.class.should == String
  end
  
  it "should generate attribute_declarations" do
    attribute_declarations = {
      {:class => 'edge', :mode => 'static'} => [{:id => "style", :title => "style", :type => "string"}],
      {:class => 'edge', :mode => 'dynamic'} => [{:id => "weight", :title => "weight", :type => "float"}],
      {:class => 'node', :mode => 'static'} => [{:id => "screen_name", :title => "screen_name", :type => "string"}],
      {:class => 'node', :mode => 'dynamic'} => [{:id => "followers_count", :title => "followers_count", :type => "int"}]
    }
    Gexf::attribute_declarations(attribute_declarations).class.should == String
  end
  
  it "should generate attribute_declaration_header" do
    attribute_declaration_header = {:class => 'node', :mode => 'static'}
    Gexf::attribute_declaration_header(attribute_declaration_header).class.should == String
  end
  
  it "should generate attribute_declaration" do
    attribute_declaration = {:id => "screen_name", :title => "screen_name", :type => "string"}  
    Gexf::attribute_declaration(attribute_declaration).class.should == String
  end
  
  it "should generate attribute_declaration_footer" do
    Gexf::attribute_declaration_footer.class.should == String
  end
  
  it "should generate footer" do
    Gexf::footer.class.should == String
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
    }]
    Gexf::nodes(nodes).class.should == String
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
    Gexf::node(node).class.should == String
  end
  
  it "should generate nodes_header" do
    Gexf::nodes_header.class.should == String
  end
  
  it "should generate node_header" do
    node = { :id => "dgaff", 
      :label => "dgaff"
    }
    Gexf::node_header(node).class.should == String
  end
  
  it "should generate node_footer" do
    Gexf::node_footer.class.should == String
  end
  
  it "should generate nodes_footer" do
    Gexf::nodes_footer.class.should == String
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
    }]
    Gexf::edges(edges).class.should == String
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
    Gexf::edge(edge).class.should == String
  end
  
  it "should generate edges_header" do
    Gexf::edges_header.class.should == String
  end
  
  it "should generate edge_header" do
    edge = {:source => "dgaff", :target => "peeinears", :start => 1, :end => 2, :weight => 2}
    Gexf::edge_header(edge).class.should == String
  end
  
  it "should generate edge_footer" do
    Gexf::edge_footer.class.should == String
  end
  
  it "should generate edges_footer" do
    Gexf::edges_footer.class.should == String
  end

  it "should generate attribute" do
    attribute = {:for => "weight", :value => 2, :start => 1, :end => 2}
    Gexf::attribute(attribute).class.should == String
  end
  
  it "should generate attributes_header" do
    Gexf::attributes_header.class.should == String
  end
  
  it "should generate attributes_footer" do
    Gexf::attributes_footer.class.should == String
  end

  it "should generate slices_header" do
    Gexf::slices_header.class.should == String
  end
  
  it "should generate slice" do
    slice = {:start => 1, :end => 2}
    Gexf::slice(slice).class.should == String
  end
  
  it "should generate slices_footer" do
    Gexf::slices_footer.class.should == String
  end
  
  it "should generate gexf_class" do
    Gexf::CLASSES.each_pair do |k, v|
      Gexf::gexf_class(k).should==v
    end
  end
  
  describe Gexf::Writer do
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
      Gexf::Writer.initialize_temp_data(fs, graph)
      Sh::sh("ls #{ENV['TMP_PATH']}").split("\n").include?("temp_header.gexf").should == true
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
      Gexf::Writer.generate_temp_data(fs, edges)
      Sh::sh("ls #{ENV['TMP_PATH']}").split("\n").include?("temp_edge.gexf").should == true
      Sh::sh("ls #{ENV['TMP_PATH']}").split("\n").include?("temp_node.gexf").should == true
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
      Gexf::Writer.finalize_temp_data(fs).class.should == Fixnum
    end
    
  end
end
