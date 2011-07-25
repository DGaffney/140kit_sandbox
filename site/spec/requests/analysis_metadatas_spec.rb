require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a analysis_metadata exists" do
  AnalysisMetadata.all.destroy!
  request(resource(:analysis_metadatas), :method => "POST", 
    :params => { :analysis_metadata => { :id => nil }})
end

describe "resource(:analysis_metadatas)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:analysis_metadatas))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of analysis_metadatas" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a analysis_metadata exists" do
    before(:each) do
      @response = request(resource(:analysis_metadatas))
    end
    
    it "has a list of analysis_metadatas" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      AnalysisMetadata.all.destroy!
      @response = request(resource(:analysis_metadatas), :method => "POST", 
        :params => { :analysis_metadata => { :id => nil }})
    end
    
    it "redirects to resource(:analysis_metadatas)" do
      @response.should redirect_to(resource(AnalysisMetadata.first), :message => {:notice => "analysis_metadata was successfully created"})
    end
    
  end
end

describe "resource(@analysis_metadata)" do 
  describe "a successful DELETE", :given => "a analysis_metadata exists" do
     before(:each) do
       @response = request(resource(AnalysisMetadata.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:analysis_metadatas))
     end

   end
end

describe "resource(:analysis_metadatas, :new)" do
  before(:each) do
    @response = request(resource(:analysis_metadatas, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@analysis_metadata, :edit)", :given => "a analysis_metadata exists" do
  before(:each) do
    @response = request(resource(AnalysisMetadata.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@analysis_metadata)", :given => "a analysis_metadata exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(AnalysisMetadata.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @analysis_metadata = AnalysisMetadata.first
      @response = request(resource(@analysis_metadata), :method => "PUT", 
        :params => { :analysis_metadata => {:id => @analysis_metadata.id} })
    end
  
    it "redirect to the analysis_metadata show action" do
      @response.should redirect_to(resource(@analysis_metadata))
    end
  end
  
end

