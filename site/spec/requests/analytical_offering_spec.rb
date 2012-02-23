require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a analytical_offering exists" do
  AnalyticalOffering.all.destroy!
  request(resource(:analytical_offering), :method => "POST", 
    :params => { :analytical_offering => { :id => nil }})
end

describe "resource(:analytical_offering)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:analytical_offering))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of analytical_offering" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a analytical_offering exists" do
    before(:each) do
      @response = request(resource(:analytical_offering))
    end
    
    it "has a list of analytical_offering" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      AnalyticalOffering.all.destroy!
      @response = request(resource(:analytical_offering), :method => "POST", 
        :params => { :analytical_offering => { :id => nil }})
    end
    
    it "redirects to resource(:analytical_offering)" do
      @response.should redirect_to(resource(AnalyticalOffering.first), :message => {:notice => "analytical_offering was successfully created"})
    end
    
  end
end

describe "resource(@analytical_offering)" do 
  describe "a successful DELETE", :given => "a analytical_offering exists" do
     before(:each) do
       @response = request(resource(AnalyticalOffering.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:analytical_offering))
     end

   end
end

describe "resource(:analytical_offering, :new)" do
  before(:each) do
    @response = request(resource(:analytical_offering, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@analytical_offering, :edit)", :given => "a analytical_offering exists" do
  before(:each) do
    @response = request(resource(AnalyticalOffering.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@analytical_offering)", :given => "a analytical_offering exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(AnalyticalOffering.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @analytical_offering = AnalyticalOffering.first
      @response = request(resource(@analytical_offering), :method => "PUT", 
        :params => { :analytical_offering => {:id => @analytical_offering.id} })
    end
  
    it "redirect to the analytical_offering show action" do
      @response.should redirect_to(resource(@analytical_offering))
    end
  end
  
end

