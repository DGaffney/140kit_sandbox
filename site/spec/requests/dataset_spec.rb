require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a dataset exists" do
  Dataset.all.destroy!
  request(resource(:dataset), :method => "POST", 
    :params => { :dataset => { :id => nil }})
end

describe "resource(:dataset)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:dataset))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of dataset" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a dataset exists" do
    before(:each) do
      @response = request(resource(:dataset))
    end
    
    it "has a list of dataset" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Dataset.all.destroy!
      @response = request(resource(:dataset), :method => "POST", 
        :params => { :dataset => { :id => nil }})
    end
    
    it "redirects to resource(:dataset)" do
      @response.should redirect_to(resource(Dataset.first), :message => {:notice => "dataset was successfully created"})
    end
    
  end
end

describe "resource(@dataset)" do 
  describe "a successful DELETE", :given => "a dataset exists" do
     before(:each) do
       @response = request(resource(Dataset.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:dataset))
     end

   end
end

describe "resource(:dataset, :new)" do
  before(:each) do
    @response = request(resource(:dataset, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@dataset, :edit)", :given => "a dataset exists" do
  before(:each) do
    @response = request(resource(Dataset.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@dataset)", :given => "a dataset exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Dataset.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @dataset = Dataset.first
      @response = request(resource(@dataset), :method => "PUT", 
        :params => { :dataset => {:id => @dataset.id} })
    end
  
    it "redirect to the dataset show action" do
      @response.should redirect_to(resource(@dataset))
    end
  end
  
end

