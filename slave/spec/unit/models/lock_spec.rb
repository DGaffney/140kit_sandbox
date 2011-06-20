describe Lock do
  it "should return all owned by me" do
    ENV['INSTANCE_ID'] = "FOO"
    locks = []
    1.upto(10) do |new_lock|
      locks << Lock.create(:classname => "TestModel", :with_id => new_lock, :instance_id => ENV['INSTANCE_ID'])
    end
    Lock.all_owned_by_me.should == locks
    locks.collect{|lock| lock.destroy!}
  end
end