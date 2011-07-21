require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a analytical_offering_variable_descriptor exists" do
  AnalyticalOfferingVariableDescriptor.all.destroy!
  request(resource(:analytical_offering_variable_descriptor), :method => "POST", 
    :params => { :analytical_offering_variable_descriptor => { :id => nil }})
end

describe "resource(:analytical_offering_variable_descriptor)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:analytical_offering_variable_descriptor))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of analytical_offering_variable_descriptor" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a analytical_offering_variable_descriptor exists" do
    before(:each) do
      @response = request(resource(:analytical_offering_variable_descriptor))
    end
    
    it "has a list of analytical_offering_variable_descriptor" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      AnalyticalOfferingVariableDescriptor.all.destroy!
      @response = request(resource(:analytical_offering_variable_descriptor), :method => "POST", 
        :params => { :analytical_offering_variable_descriptor => { :id => nil }})
    end
    
    it "redirects to resource(:analytical_offering_variable_descriptor)" do
      @response.should redirect_to(resource(AnalyticalOfferingVariableDescriptor.first), :message => {:notice => "analytical_offering_variable_descriptor was successfully created"})
    end
    
  end
end

describe "resource(@analytical_offering_variable_descriptor)" do 
  describe "a successful DELETE", :given => "a analytical_offering_variable_descriptor exists" do
     before(:each) do
       @response = request(resource(AnalyticalOfferingVariableDescriptor.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:analytical_offering_variable_descriptor))
     end

   end
end

describe "resource(:analytical_offering_variable_descriptor, :new)" do
  before(:each) do
    @response = request(resource(:analytical_offering_variable_descriptor, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@analytical_offering_variable_descriptor, :edit)", :given => "a analytical_offering_variable_descriptor exists" do
  before(:each) do
    @response = request(resource(AnalyticalOfferingVariableDescriptor.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@analytical_offering_variable_descriptor)", :given => "a analytical_offering_variable_descriptor exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(AnalyticalOfferingVariableDescriptor.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @analytical_offering_variable_descriptor = AnalyticalOfferingVariableDescriptor.first
      @response = request(resource(@analytical_offering_variable_descriptor), :method => "PUT", 
        :params => { :analytical_offering_variable_descriptor => {:id => @analytical_offering_variable_descriptor.id} })
    end
  
    it "redirect to the analytical_offering_variable_descriptor show action" do
      @response.should redirect_to(resource(@analytical_offering_variable_descriptor))
    end
  end
  
end

