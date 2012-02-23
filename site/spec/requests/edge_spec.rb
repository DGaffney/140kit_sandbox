require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a edge exists" do
  Edge.all.destroy!
  request(resource(:edge), :method => "POST", 
    :params => { :edge => { :id => nil }})
end

describe "resource(:edge)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:edge))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of edge" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a edge exists" do
    before(:each) do
      @response = request(resource(:edge))
    end
    
    it "has a list of edge" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Edge.all.destroy!
      @response = request(resource(:edge), :method => "POST", 
        :params => { :edge => { :id => nil }})
    end
    
    it "redirects to resource(:edge)" do
      @response.should redirect_to(resource(Edge.first), :message => {:notice => "edge was successfully created"})
    end
    
  end
end

describe "resource(@edge)" do 
  describe "a successful DELETE", :given => "a edge exists" do
     before(:each) do
       @response = request(resource(Edge.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:edge))
     end

   end
end

describe "resource(:edge, :new)" do
  before(:each) do
    @response = request(resource(:edge, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@edge, :edit)", :given => "a edge exists" do
  before(:each) do
    @response = request(resource(Edge.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@edge)", :given => "a edge exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Edge.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @edge = Edge.first
      @response = request(resource(@edge), :method => "PUT", 
        :params => { :edge => {:id => @edge.id} })
    end
  
    it "redirect to the edge show action" do
      @response.should redirect_to(resource(@edge))
    end
  end
  
end

