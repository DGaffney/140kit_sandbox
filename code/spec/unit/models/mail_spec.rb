describe Mail do 
  it "should save mail correctly" do
    r = Researcher.gen.save!
    m = Mail.gen.attributes
    mail = Mail.queue(m)
    mail.class.should == Mail
  end
end