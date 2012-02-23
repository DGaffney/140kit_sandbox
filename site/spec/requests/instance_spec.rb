require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a instance exists" do
  Instance.all.destroy!
  request(resource(:instance), :method => "POST", 
    :params => { :instance => { :id => nil }})
end

describe "resource(:instance)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:instance))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of instance" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a instance exists" do
    before(:each) do
      @response = request(resource(:instance))
    end
    
    it "has a list of instance" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Instance.all.destroy!
      @response = request(resource(:instance), :method => "POST", 
        :params => { :instance => { :id => nil }})
    end
    
    it "redirects to resource(:instance)" do
      @response.should redirect_to(resource(Instance.first), :message => {:notice => "instance was successfully created"})
    end
    
  end
end

describe "resource(@instance)" do 
  describe "a successful DELETE", :given => "a instance exists" do
     before(:each) do
       @response = request(resource(Instance.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:instance))
     end

   end
end

describe "resource(:instance, :new)" do
  before(:each) do
    @response = request(resource(:instance, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@instance, :edit)", :given => "a instance exists" do
  before(:each) do
    @response = request(resource(Instance.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@instance)", :given => "a instance exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Instance.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @instance = Instance.first
      @response = request(resource(@instance), :method => "PUT", 
        :params => { :instance => {:id => @instance.id} })
    end
  
    it "redirect to the instance show action" do
      @response.should redirect_to(resource(@instance))
    end
  end
  
end

