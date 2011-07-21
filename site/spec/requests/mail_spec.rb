require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a mail exists" do
  Mail.all.destroy!
  request(resource(:mail), :method => "POST", 
    :params => { :mail => { :id => nil }})
end

describe "resource(:mail)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:mail))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of mail" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a mail exists" do
    before(:each) do
      @response = request(resource(:mail))
    end
    
    it "has a list of mail" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Mail.all.destroy!
      @response = request(resource(:mail), :method => "POST", 
        :params => { :mail => { :id => nil }})
    end
    
    it "redirects to resource(:mail)" do
      @response.should redirect_to(resource(Mail.first), :message => {:notice => "mail was successfully created"})
    end
    
  end
end

describe "resource(@mail)" do 
  describe "a successful DELETE", :given => "a mail exists" do
     before(:each) do
       @response = request(resource(Mail.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:mail))
     end

   end
end

describe "resource(:mail, :new)" do
  before(:each) do
    @response = request(resource(:mail, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@mail, :edit)", :given => "a mail exists" do
  before(:each) do
    @response = request(resource(Mail.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@mail)", :given => "a mail exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Mail.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @mail = Mail.first
      @response = request(resource(@mail), :method => "PUT", 
        :params => { :mail => {:id => @mail.id} })
    end
  
    it "redirect to the mail show action" do
      @response.should redirect_to(resource(@mail))
    end
  end
  
end

