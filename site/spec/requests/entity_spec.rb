require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a entity exists" do
  Entity.all.destroy!
  request(resource(:entity), :method => "POST", 
    :params => { :entity => { :id => nil }})
end

describe "resource(:entity)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:entity))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of entity" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a entity exists" do
    before(:each) do
      @response = request(resource(:entity))
    end
    
    it "has a list of entity" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Entity.all.destroy!
      @response = request(resource(:entity), :method => "POST", 
        :params => { :entity => { :id => nil }})
    end
    
    it "redirects to resource(:entity)" do
      @response.should redirect_to(resource(Entity.first), :message => {:notice => "entity was successfully created"})
    end
    
  end
end

describe "resource(@entity)" do 
  describe "a successful DELETE", :given => "a entity exists" do
     before(:each) do
       @response = request(resource(Entity.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:entity))
     end

   end
end

describe "resource(:entity, :new)" do
  before(:each) do
    @response = request(resource(:entity, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@entity, :edit)", :given => "a entity exists" do
  before(:each) do
    @response = request(resource(Entity.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@entity)", :given => "a entity exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Entity.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @entity = Entity.first
      @response = request(resource(@entity), :method => "PUT", 
        :params => { :entity => {:id => @entity.id} })
    end
  
    it "redirect to the entity show action" do
      @response.should redirect_to(resource(@entity))
    end
  end
  
end

