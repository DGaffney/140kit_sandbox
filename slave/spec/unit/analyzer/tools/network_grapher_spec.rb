describe NetworkGrapher do
  it "should set_variables" do
    analysis_metadata, analytical_offering_function, curation = initialize_analytical_test
    analysis_metadata.set_variables.class.should == Array
    clear_test
  end
  
  it "should run" do
    analysis_metadata, analytical_offering_function, curation = initialize_analytical_test
    Analysis::Dependencies.send(analysis_metadata.function)
    analysis_metadata.set_variables!
    analysis_metadata = AnalysisMetadata.first
    analytical_offering_function.run(*analysis_metadata.run_vars).class.should == Hash
    clear_test
  end
  
  def initialize_analytical_test
    analytical_offering_function = NetworkGrapher
    analytical_offering = AnalyticalOffering.first(:function => analytical_offering_function.underscore)
    [Researcher, Curation, Dataset, User, Tweet, Graph, GraphPoint, Edge, AnalysisMetadata, Mail, AnalyticalOfferingVariable].collect{|model|
      model.destroy
    }
    researcher = Researcher.gen
    curation = Curation.gen
    dataset = Dataset.gen
    curation.datasets << dataset
    curation.researcher_id = researcher.id
    curation.save!
    researcher.save!
    analysis_metadata = AnalysisMetadata.new
    analysis_metadata.curation_id = curation.id
    analysis_metadata.analytical_offering_id = analytical_offering.id
    analysis_metadata.save!
    users = []
    tweets = []
    1.upto(10) do |user|
      user = User.gen
      user_tweets = []
      1.upto(rand(3)+1) do |tweet|
        tweet = Tweet.gen
        tweet.screen_name = user.screen_name
        tweet.user_id = user.twitter_id
        tweet.dataset_id = dataset.id
        tweet.save!
        tweets << tweet
      end
      user.dataset_id = dataset.id
      user.save!
      users << user
    end
    prior_analytical_offering_function = EdgeGenerator
    prior_analytical_offering = AnalyticalOffering.first(:function => prior_analytical_offering_function.underscore)
    prior_analysis_metadata = AnalysisMetadata.new
    prior_analysis_metadata.curation_id = curation.id
    prior_analysis_metadata.analytical_offering_id = prior_analytical_offering.id
    prior_analysis_metadata.save!
    Analysis::Dependencies.send(prior_analysis_metadata.function)
    prior_analysis_metadata.set_variables!
    prior_analysis_metadata = AnalysisMetadata.last
    prior_analytical_offering_function.run(*prior_analysis_metadata.run_vars)
    return analysis_metadata, analytical_offering_function, curation
  end
  
  def clear_test
    [Researcher, Curation, Dataset, User, Tweet, Graph, GraphPoint, Edge, AnalysisMetadata, Mail, AnalyticalOfferingVariable].collect{|model|
      model.destroy
    }
  end
end