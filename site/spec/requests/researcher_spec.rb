require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a researcher exists" do
  Researcher.all.destroy!
  request(resource(:researcher), :method => "POST", 
    :params => { :researcher => { :id => nil }})
end

describe "resource(:researcher)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:researcher))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of researcher" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a researcher exists" do
    before(:each) do
      @response = request(resource(:researcher))
    end
    
    it "has a list of researcher" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Researcher.all.destroy!
      @response = request(resource(:researcher), :method => "POST", 
        :params => { :researcher => { :id => nil }})
    end
    
    it "redirects to resource(:researcher)" do
      @response.should redirect_to(resource(Researcher.first), :message => {:notice => "researcher was successfully created"})
    end
    
  end
end

describe "resource(@researcher)" do 
  describe "a successful DELETE", :given => "a researcher exists" do
     before(:each) do
       @response = request(resource(Researcher.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:researcher))
     end

   end
end

describe "resource(:researcher, :new)" do
  before(:each) do
    @response = request(resource(:researcher, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@researcher, :edit)", :given => "a researcher exists" do
  before(:each) do
    @response = request(resource(Researcher.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@researcher)", :given => "a researcher exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Researcher.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @researcher = Researcher.first
      @response = request(resource(@researcher), :method => "PUT", 
        :params => { :researcher => {:id => @researcher.id} })
    end
  
    it "redirect to the researcher show action" do
      @response.should redirect_to(resource(@researcher))
    end
  end
  
end

