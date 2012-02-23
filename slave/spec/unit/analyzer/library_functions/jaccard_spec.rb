describe Jaccard do
  it "should return a coefficient" do
    control_text = "This is an example sentence for jaccard coefficients"
    reference_text = "jaccard coefficients are used for basic NLP."
    Jaccard.coefficient(control_text, reference_text).should == 0.2
  end
  
  it "should return an array of coefficient factors" do
    control_text = "This is an example sentence for jaccard coefficients"
    reference_text = "jaccard coefficients are used for basic NLP."
    Jaccard.coefficient_factors(control_text, reference_text).should == [["for", "jaccard", "coefficients"], ["This", "is", "an", "example", "sentence", "for", "jaccard", "coefficients", "jaccard", "coefficients", "are", "used", "for", "basic", "NLP."]]
  end
end