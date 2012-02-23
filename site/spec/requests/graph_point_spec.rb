require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a graph_point exists" do
  GraphPoint.all.destroy!
  request(resource(:graph_point), :method => "POST", 
    :params => { :graph_point => { :id => nil }})
end

describe "resource(:graph_point)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:graph_point))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of graph_point" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a graph_point exists" do
    before(:each) do
      @response = request(resource(:graph_point))
    end
    
    it "has a list of graph_point" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      GraphPoint.all.destroy!
      @response = request(resource(:graph_point), :method => "POST", 
        :params => { :graph_point => { :id => nil }})
    end
    
    it "redirects to resource(:graph_point)" do
      @response.should redirect_to(resource(GraphPoint.first), :message => {:notice => "graph_point was successfully created"})
    end
    
  end
end

describe "resource(@graph_point)" do 
  describe "a successful DELETE", :given => "a graph_point exists" do
     before(:each) do
       @response = request(resource(GraphPoint.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:graph_point))
     end

   end
end

describe "resource(:graph_point, :new)" do
  before(:each) do
    @response = request(resource(:graph_point, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@graph_point, :edit)", :given => "a graph_point exists" do
  before(:each) do
    @response = request(resource(GraphPoint.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@graph_point)", :given => "a graph_point exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(GraphPoint.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @graph_point = GraphPoint.first
      @response = request(resource(@graph_point), :method => "PUT", 
        :params => { :graph_point => {:id => @graph_point.id} })
    end
  
    it "redirect to the graph_point show action" do
      @response.should redirect_to(resource(@graph_point))
    end
  end
  
end

