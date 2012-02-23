describe "All Model Extensions" do
  before :all do
    Researcher.gen.save!
    AuthUser.gen.save!
  end
  
  it "should return attributes" do
    AuthUser.attributes.class.should == Array
  end
  
  it "should pluralize correctly" do
    Researcher.storage_name.should == Researcher.pluralize
  end
  
  it "should underscore correctly" do
    
  end
  it "should all_deleted correctly" do
    Curation.all_deleted.class.should == DataMapper::Collection
  end
  
  it "should first_deleted correctly" do
    Curation.first_deleted.class.should == (Curation || nil)
  end
  it "should find_deleted correctly" do
    Curation.find_deleted.class.should == Enumerable::Enumerator
  end
  
  it "should lock correctly" do
    auth_user = AuthUser.first
    auth_user.lock
    AuthUser.first_locked(:screen_name => auth_user.screen_name).class.should == AuthUser
  end
  
  it "should unlock correctly" do
    auth_user = AuthUser.first
    auth_user.unlock
    AuthUser.first_unlocked(:screen_name => auth_user.screen_name).class.should == AuthUser
  end
  it "should first_locked correctly" do
    Researcher.lock_all
    researcher = Researcher.last
    Researcher.first_locked(:user_name => researcher.user_name).class.should == Researcher
  end
  
  it "should first_locked correctly when none first_locked" do
    Researcher.unlock_all
    researcher = Researcher.last
    Researcher.first_locked(:user_name => researcher.user_name).class.should == NilClass
  end
  
  it "should last_locked correctly" do
    Researcher.lock_all
    researcher = Researcher.last
    Researcher.last_locked(:user_name => researcher.user_name).class.should == Researcher
  end
  
  it "should last_locked correctly when none last_locked" do
    Researcher.unlock_all
    researcher = Researcher.last
    Researcher.last_locked(:user_name => researcher.user_name).class.should == NilClass
  end
  
  it "should first_unlocked correctly" do
    Researcher.unlock_all
    researcher = Researcher.last
    Researcher.first_unlocked(:user_name => researcher.user_name).class.should == Researcher
  end
  
  it "should first_unlocked correctly when none first_unlocked" do
    Researcher.lock_all
    researcher = Researcher.last
    Researcher.first_unlocked(:user_name => researcher.user_name).class.should == NilClass
  end
  
  it "should last_unlocked correctly" do
    Researcher.unlock_all
    researcher = Researcher.last
    Researcher.last_unlocked(:user_name => researcher.user_name).class.should == Researcher
  end
  
  it "should last_unlocked correctly when none last_locked" do
    Researcher.lock_all
    researcher = Researcher.last
    Researcher.last_unlocked(:user_name => researcher.user_name).class.should == NilClass
  end
  
  it "should lock sets of objects at the class level correctly" do
    Researcher.unlock_all
    count = Researcher.count
    Researcher.lock(Researcher.all)
    count.should == Researcher.locked.count
  end

  it "should lock sets of objects in hash form at the class level correctly" do
    Researcher.unlock_all
    count = Researcher.count
    Researcher.lock(Researcher.all.collect{|researcher| researcher.attributes})
    count.should == Researcher.locked.count
  end
  
  it "should unlock sets of objects at the class level correctly" do
    Researcher.unlock_all
    count = Researcher.count
    Researcher.lock(Researcher.all)
    count.should == Researcher.locked.count
  end
  
  it "should unlock sets of objects in hash form at the class level correctly" do
    Researcher.lock_all
    count = Researcher.count
    Researcher.unlock(Researcher.all.collect{|researcher| researcher.attributes})
    count.should == Researcher.unlocked.count
  end
  
  it "should unlock! when I own it" do
    Researcher.unlock_all
    Researcher.first.lock
    Researcher.first.unlock!.should == Researcher.first
  end
  
  it "should unlock! when already unlocked" do
    Researcher.unlock_all
    Researcher.first.unlock!.should == nil
  end
  
  it "should unlock! when I don't own it" do
    Researcher.unlock_all
    Researcher.lock_all
    Researcher.first.unlock!.should == Researcher.first    
  end

  it "should state owned_by_me?" do
    result = Researcher.first.owned_by_me?.class
    [TrueClass,FalseClass].include?(result).should == true
  end
  
  it "should state owned?" do
    result = Researcher.first.owned?.class
    [TrueClass,FalseClass].include?(result).should == true
  end
  
  it "should state owned_by_me? as true when I own it" do
    Researcher.unlock_all
    Researcher.first.lock
    Researcher.first.owned_by_me?.should == true
  end
  
  it "should state owned? as true when I own it" do
    Researcher.unlock_all
    Researcher.first.lock
    Researcher.first.owned?.should == true
  end
  
  it "should state owned_by_me? as false when I don't own it" do
    Researcher.lock_all
    Researcher.first.owned_by_me?.should == false
  end
  
  it "should state owned? as false when someone else owns it" do
    Researcher.lock_all
    Researcher.first.owned?.should == true
  end
  
  it "should state owned? as false when no one owns it" do
    Researcher.unlock_all
    Researcher.first.owned?.should == false
  end
  
  it "should lock_all correctly" do
    count = Curation.count
    Curation.lock_all
    Curation.locked.count.should == count
  end
  
  it "should unlock_all correctly" do
    count = Curation.count
    Curation.unlock_all
    Curation.unlocked.count.should == count
  end
  
  it "should unlock! batches of objects at the class level" do
    Researcher.lock_all
    count = Researcher.count
    Researcher.unlock!(Researcher.all.collect{|researcher| researcher.attributes})
    count.should == Researcher.unlocked.count
  end

  it "should unlock! batches of objects in hash form at the class level" do
    Researcher.unlock_all
    Researcher.first.owned?.should == false    
  end
  
  it "should save_all objects correctly" do
    auth_users = []
    1.upto(100) do |auth_user|
      auth_users << AuthUser.gen
    end
    attributes = auth_users.collect{|au| au.attributes}
    auth_users.collect{|au| au.destroy}
    AuthUser.save_all(attributes)
  end
  
  it "should update_all objects correctly" do
    auth_users = []
    1.upto(100) do |auth_user|
      auth_users << AuthUser.gen
    end
    attributes = auth_users.collect{|au| au.attributes}
    AuthUser.update_all(attributes)
  end
end