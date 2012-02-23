require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a auth_user exists" do
  AuthUser.all.destroy!
  request(resource(:auth_user), :method => "POST", 
    :params => { :auth_user => { :id => nil }})
end

describe "resource(:auth_user)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:auth_user))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of auth_user" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a auth_user exists" do
    before(:each) do
      @response = request(resource(:auth_user))
    end
    
    it "has a list of auth_user" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      AuthUser.all.destroy!
      @response = request(resource(:auth_user), :method => "POST", 
        :params => { :auth_user => { :id => nil }})
    end
    
    it "redirects to resource(:auth_user)" do
      @response.should redirect_to(resource(AuthUser.first), :message => {:notice => "auth_user was successfully created"})
    end
    
  end
end

describe "resource(@auth_user)" do 
  describe "a successful DELETE", :given => "a auth_user exists" do
     before(:each) do
       @response = request(resource(AuthUser.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:auth_user))
     end

   end
end

describe "resource(:auth_user, :new)" do
  before(:each) do
    @response = request(resource(:auth_user, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@auth_user, :edit)", :given => "a auth_user exists" do
  before(:each) do
    @response = request(resource(AuthUser.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@auth_user)", :given => "a auth_user exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(AuthUser.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @auth_user = AuthUser.first
      @response = request(resource(@auth_user), :method => "PUT", 
        :params => { :auth_user => {:id => @auth_user.id} })
    end
  
    it "redirect to the auth_user show action" do
      @response.should redirect_to(resource(@auth_user))
    end
  end
  
end

