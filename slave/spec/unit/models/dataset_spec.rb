describe Dataset do
  it "should return scrape_types" do
    Dataset.scrape_types.class.should == Array
  end

  it "should valid_params for valid track params" do
    Dataset.valid_params("track", "lol").should == {:reason=>"", :clean_params=>"lol"}
  end

  it "should valid_params for valid follow params" do
    Dataset.valid_params("follow", "lol").should == {:reason=>"", :clean_params=>"199443353"}
  end

  it "should valid_params for multiple valid follow params" do
    Dataset.valid_params("follow", "lol,dgaff").should == {:reason=>"", :clean_params=>"199443353,13731562"}
  end
  
  it "should valid_params for valid locations params" do
    Dataset.valid_params("locations", "-42,70,-43,71").should == {:reason=>"", :clean_params=>"-42.0,70.0,-43.0,71.0"}
  end
  
  it "should valid_params for valid import params twapper" do
    Dataset.valid_params("import", "www.twapperkeeper.com/sample-data.json").should == {:reason=>"", :clean_params=>"www.twapperkeeper.com/sample-data.json"}
  end

  it "should valid_params for valid import params 140kit" do
    Dataset.valid_params("import", "www.140kit.com/sample-data.json").should == {:reason=>"", :clean_params=>"www.140kit.com/sample-data.json"}
  end

  it "should valid_params for valid audience_profile params" do
    Dataset.valid_params("audience_profile", "dgaff").should == {:reason=>"", :clean_params=>"dgaff"}
  end

  it "should not valid_params for invalid import params" do
    Dataset.valid_params("import", "www.").should == {:reason=>"File does not exist locally", :clean_params=>""}
  end

  it "should not valid_params for invalid audience_profile params" do
    Dataset.valid_params("audience_profile", "aofijaewfojewifaowighalweriuhgalewrgiuahwlgiuah").should == {:reason=>"No User found with name aofijaewfojewifaowighalweriuhgalewrgiuahwlgiuah", :clean_params=>""}
  end

  it "should not valid_params for empty audience_profile params" do
    Dataset.valid_params("audience_profile", "").should == {:reason=>"No User found with name ", :clean_params=>""}
  end

  it "should not valid_params for invalid track params" do
    Dataset.valid_params("track", "").should == {:reason=>"The term can't be empty", :clean_params=>""}
  end

  it "should not valid_params for invalid follow params" do
    Dataset.valid_params("follow", "iwjeojefwopi").should == {:reason=>"No User found with name iwjeojefwopi", :clean_params=>""}
  end

  it "should not valid_params for locations of wrong coord length" do
    Dataset.valid_params("locations", "-42,70").should == {:reason=>"Must input two pairs of numbers, separated by commas.", :clean_params=>""}
  end

  it "should not valid_params for locations of zero area" do
    Dataset.valid_params("locations", "-42,70,-43,70").should == {:reason=>"Total Area of this box is zero - must make a real box", :clean_params=>""}
  end

  it "should not valid_params for locations of more than one degree latitude" do
    Dataset.valid_params("locations", "-42,70,-44,71").should == {:reason=>"Latitudes cover more than one degree of area", :clean_params=>""}
  end

  it "should not valid_params for locations of more than one degree longitude" do
    Dataset.valid_params("locations", "-42,70,-43,72").should == {:reason=>"Longitudes cover more than one degree of area", :clean_params=>""}
  end

  it "should not valid_params for locations of out of range latitude" do
    Dataset.valid_params("locations", "-100,70,-101,71").should == {:reason=>"Latitudes are out of range (max 90 degrees)", :clean_params=>""}
  end

  it "should not valid_params for locations of out of range longitude" do
    Dataset.valid_params("locations", "-42,189,-43,190").should == {:reason=>"Longitudes are out of range (max 180 degrees)", :clean_params=>""}
  end
  
  it "should full delete a dataset" do
    tweets = []
    entities = []
    users = []
    friendships = []
    dataset = Dataset.gen
    1.upto(100) do |gen_sample|
      user = User.gen
      user.dataset_id = dataset.id
      user.save
      users << user
      tweet = Tweet.gen
      tweet.dataset_id = dataset.id
      tweet.save
      tweets << tweet
      entity = Entity.gen
      entity.dataset_id = dataset.id
      entity.save
      entities << entity
      friendship = Friendship.gen
      friendship.dataset_id = dataset.id
      friendship.save
      friendships << friendship
    end
    dataset.full_delete.should == true
    Tweet.count(:id => tweets.collect{|t| t.id}).should == 0
    Entity.count(:id => entities.collect{|e| e.id}).should == 0
    User.count(:id => users.collect{|u| u.id}).should == 0
    Friendship.count(:id => friendships.collect{|f| f.id}).should == 0
  end
end