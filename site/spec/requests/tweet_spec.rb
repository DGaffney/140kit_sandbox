require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a tweet exists" do
  Tweet.all.destroy!
  request(resource(:tweet), :method => "POST", 
    :params => { :tweet => { :id => nil }})
end

describe "resource(:tweet)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:tweet))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of tweet" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a tweet exists" do
    before(:each) do
      @response = request(resource(:tweet))
    end
    
    it "has a list of tweet" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Tweet.all.destroy!
      @response = request(resource(:tweet), :method => "POST", 
        :params => { :tweet => { :id => nil }})
    end
    
    it "redirects to resource(:tweet)" do
      @response.should redirect_to(resource(Tweet.first), :message => {:notice => "tweet was successfully created"})
    end
    
  end
end

describe "resource(@tweet)" do 
  describe "a successful DELETE", :given => "a tweet exists" do
     before(:each) do
       @response = request(resource(Tweet.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:tweet))
     end

   end
end

describe "resource(:tweet, :new)" do
  before(:each) do
    @response = request(resource(:tweet, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@tweet, :edit)", :given => "a tweet exists" do
  before(:each) do
    @response = request(resource(Tweet.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@tweet)", :given => "a tweet exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Tweet.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @tweet = Tweet.first
      @response = request(resource(@tweet), :method => "PUT", 
        :params => { :tweet => {:id => @tweet.id} })
    end
  
    it "redirect to the tweet show action" do
      @response.should redirect_to(resource(@tweet))
    end
  end
  
end

