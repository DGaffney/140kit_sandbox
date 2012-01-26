describe EntityHelper do
  it "should prepped_entities correctly" do
    sample_entity_hash = 
    {:entities=>
      { :urls=>
        [
          {:indices=>[21, 40], :expanded_url=>"http://twitpic.com/48k34k", :url=>"http://t.co/26e8KGZ", :display_url=>"twitpic.com/48k34k"}
        ], 
        :user_mentions=>[
          {:indices=>[0, 15], :id_str=>"16367272", :screen_name=>"yourscenesucks", :name=>"pete wentz", :id=>16367272}
        ], 
        :hashtags=>[
          {:text=>"nerdbird", :indices=>[61, 70]}
        ]
      }
    }
    result = EntityHelper.prepped_entities(sample_entity_hash)
    result.class.should == Array && result.length.should == 6
  end
end