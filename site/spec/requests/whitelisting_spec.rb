require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a whitelisting exists" do
  Whitelisting.all.destroy!
  request(resource(:whitelisting), :method => "POST", 
    :params => { :whitelisting => { :id => nil }})
end

describe "resource(:whitelisting)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:whitelisting))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of whitelisting" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a whitelisting exists" do
    before(:each) do
      @response = request(resource(:whitelisting))
    end
    
    it "has a list of whitelisting" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Whitelisting.all.destroy!
      @response = request(resource(:whitelisting), :method => "POST", 
        :params => { :whitelisting => { :id => nil }})
    end
    
    it "redirects to resource(:whitelisting)" do
      @response.should redirect_to(resource(Whitelisting.first), :message => {:notice => "whitelisting was successfully created"})
    end
    
  end
end

describe "resource(@whitelisting)" do 
  describe "a successful DELETE", :given => "a whitelisting exists" do
     before(:each) do
       @response = request(resource(Whitelisting.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:whitelisting))
     end

   end
end

describe "resource(:whitelisting, :new)" do
  before(:each) do
    @response = request(resource(:whitelisting, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@whitelisting, :edit)", :given => "a whitelisting exists" do
  before(:each) do
    @response = request(resource(Whitelisting.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@whitelisting)", :given => "a whitelisting exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Whitelisting.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @whitelisting = Whitelisting.first
      @response = request(resource(@whitelisting), :method => "PUT", 
        :params => { :whitelisting => {:id => @whitelisting.id} })
    end
  
    it "redirect to the whitelisting show action" do
      @response.should redirect_to(resource(@whitelisting))
    end
  end
  
end

