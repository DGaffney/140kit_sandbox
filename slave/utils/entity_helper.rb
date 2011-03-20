#Entities come into our system looking like this:
#
#
#
#
#  
# { :urls=>
#   [
#     {:indices=>[21, 40], :expanded_url=>"http://twitpic.com/48k34k", :url=>"http://t.co/26e8KGZ", :display_url=>"twitpic.com/48k34k"}
#   ], 
#   :user_mentions=>[
#     {:indices=>[0, 15], :id_str=>"16367272", :screen_name=>"yourscenesucks", :name=>"pete wentz", :id=>16367272}
#   ], 
#   :hashtags=>[
#     {:text=>"nerdbird", :indices=>[61, 70]}
#   ]
# }



class EntityHelper
  @@allowed_entity_names = [:expanded_url, :url, :display_url, :id, :screen_name, :text]
  def self.prepped_entities(json)
    clean_entities = []
    json[:entities].each_pair do |kind,entities|
      entities.each do |entity|
        entity.each do |name,value|
          if @@allowed_entity_names.include?(name)
            clean_entities << {:kind => kind.to_s, :name => name.to_s, :value => value.to_s, :twitter_id => json[:id]} if !value.nil?
          end
        end
      end
    end
    return clean_entities
  end
end