describe Graphml do
  it "should generate header" do
    Graphml::header.class.should == String
  end
  
  it "should generate attribute_declarations" do
    attribute_declarations = {
      {:class => 'edge', :mode => 'static'} => [{:id => "style", :title => "style", :type => "string"}],
      {:class => 'edge', :mode => 'dynamic'} => [{:id => "weight", :title => "weight", :type => "float"}],
      {:class => 'node', :mode => 'static'} => [{:id => "screen_name", :title => "screen_name", :type => "string"}],
      {:class => 'node', :mode => 'dynamic'} => [{:id => "followers_count", :title => "followers_count", :type => "int"}]
    }
    Graphml::attribute_declarations(attribute_declarations).class.should == String
  end
  
  it "should generate attribute_declaration_header" do
    attribute_declaration_header = {:class => 'node', :mode => 'static'}
    Graphml::attribute_declaration_header(attribute_declaration_header).class.should == String
  end
  
  it "should generate attribute_declaration" do
    attribute_declaration = {:id => "screen_name", :title => "screen_name", :type => "string"}  
    Graphml::attribute_declaration(attribute_declaration).class.should == String
  end
  
  it "should generate attribute_declaration_footer" do
    Graphml::attribute_declaration_footer.class.should == String
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
    }]
    Graphml::nodes(nodes).class.should == "String"
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
    Graphml::node(node).class.should == "String"
  end
  
  it "should generate nodes_header" do
    Graphml::nodes_header.class.should == String
  end
  
  it "should generate node_header" do
    node = { :id => "dgaff", 
      :label => "dgaff"
    }
    Graphml::node_header(node).class.should == "String"
  end
  
  it "should generate node_footer" do
    Graphml::node_footer.class.should == String
  end
  
  it "should generate nodes_footer" do
    Graphml::nodes_footer.class.should == String
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
    Graphml::edges(edges).class.should == String
  end
  
  it "should generate edge" do
    edges = { :source => "dgaff", 
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
  
  it "should generate edges_header" do
    Graphml::edges_header.class.should == String
  end
  
  it "should generate edge_header" do
    edge = {:source => "dgaff", :target => "peeinears", :start => 1, :end => 2, :weight => 2}
    Graphml::edge_header(edge).class.should == String
  end
  
  it "should generate edge_footer" do
    Graphml::edge_footer.class.should == String
  end
  
  it "should generate edges_footer" do
    Graphml::edges_footer.class.should == String
  end

  it "should generate attribute" do
    attribute = {:for => "weight", :value => 2, :start => 1, :end => 2}
    Graphml::attribute(attribute).class.should == String
  end
  
  it "should generate attributes_header" do
    Graphml::attributes_header.class.should == String
  end
  
  it "should generate attributes_footer" do
    Graphml::attributes_footer.class.should == String
  end

  it "should generate slices_header" do
    Graphml::slices_header.class.should == String
  end
  
  it "should generate slice" do
    slice = {:start => 1, :end => 2}
    Graphml::slice(slice).class.should == String
  end
  
  it "should generate slices_footer" do
    Graphml::slices_footer.class.should == String
  end
  
  it "should generate Graphml_class" do
    Graphml::CLASSES.each_pair do |k, v|
      Graphml::Graphml_class(k).should==v
    end
  end
  
  describe Graphml::Writer do
    it "should generate a legitimate file" do
      1.upto(100) do |edge|
      end
    end
  end
end
