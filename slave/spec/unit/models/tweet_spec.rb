describe Tweet do 
  before :all do
    debugger
    researcher = Researcher.gen
    researcher.save!
    dataset = Dataset.gen
    dataset.save!
    curation = Curation.gen
    curation.save!
    curation.datasets << dataset
    curation.save!
    user = User.gen
    user.save!
  end
  
  it "should return entities as an array" do
    tweet = Tweet.gen
    tweet.entities.class.should == DataMapper::Associations::OneToMany::Collection
  end
end