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
    Gexf::nodes(nodes).class.should == "String"
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
    Gexf::node(node).class.should == "String"
  end
  
  it "should generate nodes_header" do
    Gexf::nodes_header.class.should == String
  end
  
  it "should generate node_header" do
    node = { :id => "dgaff", 
      :label => "dgaff"
    }
    Gexf::node_header(node).class.should == "String"
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
    it "should generate a legitimate file" do
      1.upto(100) do |edge|
      end
    end
  end
end
