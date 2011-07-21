require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a importer_task exists" do
  ImporterTask.all.destroy!
  request(resource(:importer_task), :method => "POST", 
    :params => { :importer_task => { :id => nil }})
end

describe "resource(:importer_task)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:importer_task))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of importer_task" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a importer_task exists" do
    before(:each) do
      @response = request(resource(:importer_task))
    end
    
    it "has a list of importer_task" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      ImporterTask.all.destroy!
      @response = request(resource(:importer_task), :method => "POST", 
        :params => { :importer_task => { :id => nil }})
    end
    
    it "redirects to resource(:importer_task)" do
      @response.should redirect_to(resource(ImporterTask.first), :message => {:notice => "importer_task was successfully created"})
    end
    
  end
end

describe "resource(@importer_task)" do 
  describe "a successful DELETE", :given => "a importer_task exists" do
     before(:each) do
       @response = request(resource(ImporterTask.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:importer_task))
     end

   end
end

describe "resource(:importer_task, :new)" do
  before(:each) do
    @response = request(resource(:importer_task, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@importer_task, :edit)", :given => "a importer_task exists" do
  before(:each) do
    @response = request(resource(ImporterTask.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@importer_task)", :given => "a importer_task exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(ImporterTask.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @importer_task = ImporterTask.first
      @response = request(resource(@importer_task), :method => "PUT", 
        :params => { :importer_task => {:id => @importer_task.id} })
    end
  
    it "redirect to the importer_task show action" do
      @response.should redirect_to(resource(@importer_task))
    end
  end
  
end

