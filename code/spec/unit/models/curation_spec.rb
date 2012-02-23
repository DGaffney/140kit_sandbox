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
end
