class Location
  include DataMapper::Resource
  property :id,   Serial
  property :woeid, Integer
  property :name, String
  property :parent_id, Integer
  property :place_code, Integer
  property :place_code_name, String
  property :country, String
  property :country_code, String
  property :dataset_id, Integer
end