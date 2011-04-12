describe Researcher do
  PASSWORD = Digest::SHA1.hexdigest(rand(1000).to_s)
  before :all do
    researcher = Researcher.gen
    researcher.password = PASSWORD
    researcher.send("encrypt_password")
    researcher.save!
  end
  
  it "should authenticate user" do
    researcher = Researcher.last
    result = Researcher.authenticate(researcher.user_name, PASSWORD)
    result.class.should == Researcher
  end
  
  it "should remember_token? as nil" do
    researcher = Researcher.last
    researcher.remember_token?.should == nil
  end
  
  it "should remember_token? as something if remember_me is called" do
    researcher = Researcher.last
    researcher.remember_me
    researcher.remember_token?.should == true
  end
  
  it "should forget_me correctly" do
    researcher = Researcher.last
    researcher.forget_me.should == true
  end
  
  it "should validate_on_create correctly" do
    researcher = Researcher.last
    researcher.validate_on_create.first.should == true
  end

  it "should validate_on_create fail on bad name" do
    researcher = Researcher.last
    researcher.user_name = "@$#%)(*{})$()})}Harold"
    researcher.validate_on_create.first.should == false
  end
  
  it "should register as admin? correctly" do
    researcher = Researcher.last
    researcher.role = "Admin"
    researcher.save!
    researcher.admin?.should == true
  end
  
  it "should not require a password for a saved user" do
    researcher = Researcher.last
    researcher.send("password_required?").should == false
  end
  
  it "should require a password for a saved user" do
    researcher = Researcher.gen
    researcher.send("password_required?").should == true
  end
end