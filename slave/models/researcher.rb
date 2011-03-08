class Researcher
  include DataMapper::Resource
  property :id, Serial
  property :user_name, String
  property :email, Text
  property :reset_code, String
  property :role, String
  property :join_date, DateTime
  property :last_login, DateTime
  property :last_access, DateTime
  property :info, Text
  property :website_url, Text
  property :location, String
  property :salt, String
  property :remember_token, String
  property :remember_token_expires_at, DateTime
  property :crypted_password, String
  property :share_email, Boolean
  property :private_data, Boolean
  property :hidden_account, Boolean
  property :rate_limited, Boolean
end
