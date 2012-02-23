require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a friendship exists" do
  Friendship.all.destroy!
  request(resource(:friendship), :method => "POST", 
    :params => { :friendship => { :id => nil }})
end

describe "resource(:friendship)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:friendship))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of friendship" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a friendship exists" do
    before(:each) do
      @response = request(resource(:friendship))
    end
    
    it "has a list of friendship" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Friendship.all.destroy!
      @response = request(resource(:friendship), :method => "POST", 
        :params => { :friendship => { :id => nil }})
    end
    
    it "redirects to resource(:friendship)" do
      @response.should redirect_to(resource(Friendship.first), :message => {:notice => "friendship was successfully created"})
    end
    
  end
end

describe "resource(@friendship)" do 
  describe "a successful DELETE", :given => "a friendship exists" do
     before(:each) do
       @response = request(resource(Friendship.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:friendship))
     end

   end
end

describe "resource(:friendship, :new)" do
  before(:each) do
    @response = request(resource(:friendship, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@friendship, :edit)", :given => "a friendship exists" do
  before(:each) do
    @response = request(resource(Friendship.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@friendship)", :given => "a friendship exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Friendship.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @friendship = Friendship.first
      @response = request(resource(@friendship), :method => "PUT", 
        :params => { :friendship => {:id => @friendship.id} })
    end
  
    it "redirect to the friendship show action" do
      @response.should redirect_to(resource(@friendship))
    end
  end
  
end

