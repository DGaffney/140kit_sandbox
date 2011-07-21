require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a curation exists" do
  Curation.all.destroy!
  request(resource(:curation), :method => "POST", 
    :params => { :curation => { :id => nil }})
end

describe "resource(:curation)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:curation))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of curation" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a curation exists" do
    before(:each) do
      @response = request(resource(:curation))
    end
    
    it "has a list of curation" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Curation.all.destroy!
      @response = request(resource(:curation), :method => "POST", 
        :params => { :curation => { :id => nil }})
    end
    
    it "redirects to resource(:curation)" do
      @response.should redirect_to(resource(Curation.first), :message => {:notice => "curation was successfully created"})
    end
    
  end
end

describe "resource(@curation)" do 
  describe "a successful DELETE", :given => "a curation exists" do
     before(:each) do
       @response = request(resource(Curation.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:curation))
     end

   end
end

describe "resource(:curation, :new)" do
  before(:each) do
    @response = request(resource(:curation, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@curation, :edit)", :given => "a curation exists" do
  before(:each) do
    @response = request(resource(Curation.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@curation)", :given => "a curation exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Curation.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @curation = Curation.first
      @response = request(resource(@curation), :method => "PUT", 
        :params => { :curation => {:id => @curation.id} })
    end
  
    it "redirect to the curation show action" do
      @response.should redirect_to(resource(@curation))
    end
  end
  
end

