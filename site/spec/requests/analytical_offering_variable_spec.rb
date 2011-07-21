require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a analytical_offering_variable exists" do
  AnalyticalOfferingVariable.all.destroy!
  request(resource(:analytical_offering_variable), :method => "POST", 
    :params => { :analytical_offering_variable => { :id => nil }})
end

describe "resource(:analytical_offering_variable)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:analytical_offering_variable))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of analytical_offering_variable" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a analytical_offering_variable exists" do
    before(:each) do
      @response = request(resource(:analytical_offering_variable))
    end
    
    it "has a list of analytical_offering_variable" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      AnalyticalOfferingVariable.all.destroy!
      @response = request(resource(:analytical_offering_variable), :method => "POST", 
        :params => { :analytical_offering_variable => { :id => nil }})
    end
    
    it "redirects to resource(:analytical_offering_variable)" do
      @response.should redirect_to(resource(AnalyticalOfferingVariable.first), :message => {:notice => "analytical_offering_variable was successfully created"})
    end
    
  end
end

describe "resource(@analytical_offering_variable)" do 
  describe "a successful DELETE", :given => "a analytical_offering_variable exists" do
     before(:each) do
       @response = request(resource(AnalyticalOfferingVariable.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:analytical_offering_variable))
     end

   end
end

describe "resource(:analytical_offering_variable, :new)" do
  before(:each) do
    @response = request(resource(:analytical_offering_variable, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@analytical_offering_variable, :edit)", :given => "a analytical_offering_variable exists" do
  before(:each) do
    @response = request(resource(AnalyticalOfferingVariable.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@analytical_offering_variable)", :given => "a analytical_offering_variable exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(AnalyticalOfferingVariable.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @analytical_offering_variable = AnalyticalOfferingVariable.first
      @response = request(resource(@analytical_offering_variable), :method => "PUT", 
        :params => { :analytical_offering_variable => {:id => @analytical_offering_variable.id} })
    end
  
    it "redirect to the analytical_offering_variable show action" do
      @response.should redirect_to(resource(@analytical_offering_variable))
    end
  end
  
end

