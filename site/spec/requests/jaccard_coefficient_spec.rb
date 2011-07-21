require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a jaccard_coefficient exists" do
  JaccardCoefficient.all.destroy!
  request(resource(:jaccard_coefficient), :method => "POST", 
    :params => { :jaccard_coefficient => { :id => nil }})
end

describe "resource(:jaccard_coefficient)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:jaccard_coefficient))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of jaccard_coefficient" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a jaccard_coefficient exists" do
    before(:each) do
      @response = request(resource(:jaccard_coefficient))
    end
    
    it "has a list of jaccard_coefficient" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      JaccardCoefficient.all.destroy!
      @response = request(resource(:jaccard_coefficient), :method => "POST", 
        :params => { :jaccard_coefficient => { :id => nil }})
    end
    
    it "redirects to resource(:jaccard_coefficient)" do
      @response.should redirect_to(resource(JaccardCoefficient.first), :message => {:notice => "jaccard_coefficient was successfully created"})
    end
    
  end
end

describe "resource(@jaccard_coefficient)" do 
  describe "a successful DELETE", :given => "a jaccard_coefficient exists" do
     before(:each) do
       @response = request(resource(JaccardCoefficient.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:jaccard_coefficient))
     end

   end
end

describe "resource(:jaccard_coefficient, :new)" do
  before(:each) do
    @response = request(resource(:jaccard_coefficient, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@jaccard_coefficient, :edit)", :given => "a jaccard_coefficient exists" do
  before(:each) do
    @response = request(resource(JaccardCoefficient.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@jaccard_coefficient)", :given => "a jaccard_coefficient exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(JaccardCoefficient.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @jaccard_coefficient = JaccardCoefficient.first
      @response = request(resource(@jaccard_coefficient), :method => "PUT", 
        :params => { :jaccard_coefficient => {:id => @jaccard_coefficient.id} })
    end
  
    it "redirect to the jaccard_coefficient show action" do
      @response.should redirect_to(resource(@jaccard_coefficient))
    end
  end
  
end

