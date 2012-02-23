require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a lock exists" do
  Lock.all.destroy!
  request(resource(:lock), :method => "POST", 
    :params => { :lock => { :id => nil }})
end

describe "resource(:lock)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:lock))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of lock" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a lock exists" do
    before(:each) do
      @response = request(resource(:lock))
    end
    
    it "has a list of lock" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Lock.all.destroy!
      @response = request(resource(:lock), :method => "POST", 
        :params => { :lock => { :id => nil }})
    end
    
    it "redirects to resource(:lock)" do
      @response.should redirect_to(resource(Lock.first), :message => {:notice => "lock was successfully created"})
    end
    
  end
end

describe "resource(@lock)" do 
  describe "a successful DELETE", :given => "a lock exists" do
     before(:each) do
       @response = request(resource(Lock.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:lock))
     end

   end
end

describe "resource(:lock, :new)" do
  before(:each) do
    @response = request(resource(:lock, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@lock, :edit)", :given => "a lock exists" do
  before(:each) do
    @response = request(resource(Lock.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@lock)", :given => "a lock exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Lock.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @lock = Lock.first
      @response = request(resource(@lock), :method => "PUT", 
        :params => { :lock => {:id => @lock.id} })
    end
  
    it "redirect to the lock show action" do
      @response.should redirect_to(resource(@lock))
    end
  end
  
end

