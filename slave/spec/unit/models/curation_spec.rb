require 'spec_helper'

describe Curation do
  before :all do
    Researcher.gen.save!
    1.upto(50) {|x| dataset = Dataset.gen;dataset.save}
  end

  it "should not be valid without a researcher specified" do
    curation = Curation.gen
    curation.researcher_id = nil
    curation.save!
    curation.valid?.should == false
  end

  it "should not be valid without a researcher specified" do
    curation = Curation.gen
    curation.name = nil
    curation.save!
    curation.valid?.should == false
  end

  it "should be valid with everything set" do
    curation = Curation.gen
    curation.save!
    curation.valid?.should == true
  end
  
  it "should return a stored folder name" do
    curation = Curation.gen
    curation.save!
    curation.stored_folder_name.class.should == String
  end

  it "should return an int for tweets count" do
    curation = Curation.gen
    curation.save!
    curation.tweets_count.class.should == Fixnum || curation.tweets_count.class.should == Bignum
  end

  it "should return an int for users count" do
    curation = Curation.gen
    curation.save!
    curation.users_count.class.should == Fixnum || curation.users_count.class.should == Bignum
  end
  
  it "should full_delete without errors" do
    tweets = []
    entities = []
    users = []
    friendships = []
    dataset = Dataset.gen
    1.upto(10) do |gen_sample|
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
    curation = Curation.gen
    curation.datasets << dataset
    dataset.save
    curation.save
    am = AnalysisMetadata.gen
    am.analytical_offering_id = AnalyticalOffering.first(:function => "network_grapher").id
    am.curation_id = curation.id
    am.save!
    curation.full_delete.should == true
  end
  
  it "should return a still_collecting? status for any type of curation" do
    curation = Curation.gen
    1.upto(10) do |dataset|
      dataset = Dataset.gen
      curation.datasets << dataset
      curation.save!
      dataset.save!
    end
    [true, false].include?(curation.still_collecting?).should == true
  end
end
