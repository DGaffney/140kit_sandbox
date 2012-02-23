class AuthUser
  include DataMapper::Resource
  property :id, Serial
  property :screen_name, String, :unique_index => [:unique_auth_user]
  property :password, String, :unique_index => [:unique_auth_user]
  property :instance_id, String, :length => 40
end