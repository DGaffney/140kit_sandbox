describe U do
  it "should times_up true when time is up" do
    U.times_up?(Time.now-1.day).should == true
  end
  
  it "should times_up false when time is not up" do
    U.times_up?(Time.now+1.day).should == false
  end
  
  it "should return_data from a series of urls" do
    urls = ["http://twitter.com/account/rate_limit_status.json"]
    urls.each do |url|
      U.return_data(url).should_not == nil
    end
  end
  
  it "should return_data with 401 if user is protected" do
    protected_url = "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=sfgainey"
    result = U.return_data(protected_url, false)
    result.should == nil
  end
  
  it "should return days for every month" do
    2000.upto(2010) do |year|
      1.upto(12) do |month|
        U.month_days(month, year).should >= 28
      end
    end
  end
end