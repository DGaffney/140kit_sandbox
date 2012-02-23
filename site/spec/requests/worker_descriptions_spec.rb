require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a worker_description exists" do
  WorkerDescription.all.destroy!
  request(resource(:worker_descriptions), :method => "POST", 
    :params => { :worker_description => { :id => nil }})
end

describe "resource(:worker_descriptions)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:worker_descriptions))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of worker_descriptions" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a worker_description exists" do
    before(:each) do
      @response = request(resource(:worker_descriptions))
    end
    
    it "has a list of worker_descriptions" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      WorkerDescription.all.destroy!
      @response = request(resource(:worker_descriptions), :method => "POST", 
        :params => { :worker_description => { :id => nil }})
    end
    
    it "redirects to resource(:worker_descriptions)" do
      @response.should redirect_to(resource(WorkerDescription.first), :message => {:notice => "worker_description was successfully created"})
    end
    
  end
end

describe "resource(@worker_description)" do 
  describe "a successful DELETE", :given => "a worker_description exists" do
     before(:each) do
       @response = request(resource(WorkerDescription.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:worker_descriptions))
     end

   end
end

describe "resource(:worker_descriptions, :new)" do
  before(:each) do
    @response = request(resource(:worker_descriptions, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@worker_description, :edit)", :given => "a worker_description exists" do
  before(:each) do
    @response = request(resource(WorkerDescription.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@worker_description)", :given => "a worker_description exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(WorkerDescription.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @worker_description = WorkerDescription.first
      @response = request(resource(@worker_description), :method => "PUT", 
        :params => { :worker_description => {:id => @worker_description.id} })
    end
  
    it "redirect to the worker_description show action" do
      @response.should redirect_to(resource(@worker_description))
    end
  end
  
end

