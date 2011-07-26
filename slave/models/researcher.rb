class Researcher
  include DataMapper::Resource
  property :id, Serial
  property :user_name, String, :format => /[A-Za-z0-9_]*/, :length => 3..40
  property :email, Text, :default => "user@localhost.com", :format => :email_address
  property :reset_code, String
  property :role, String, :default => "Admin"
  property :join_date, Time, :default => Time.now
  property :last_login, Time
  property :last_access, Time
  property :info, Text, :default => "I like to study the internet"
  property :website_url, Text, :default => "http://140kit.com/", :format => :url
  property :location, String, :default => "The Internet"
  property :salt, String
  property :remember_token, String
  property :remember_token_expires_at, Time
  property :crypted_password, String
  property :share_email, Boolean, :default => false
  property :private_data, Boolean, :default => false
  property :hidden_account, Boolean, :default => false
  property :rate_limited, Boolean, :default => false
  has n, :curations
  has n, :datasets, :through => :curations
  attr_accessor :password
  
  alias :login :user_name
  alias :created_at :join_date
  validates_length      :password, :within => 4..40, :if => :password_required?
    
  def self.authenticate(user_name, password)
    u = first(:user_name => user_name) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = Time.now.utc+2.weeks
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    self.save!
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    self.save!
  end
  
  def validate_on_create
    if !self.user_name.scan(/[\.\;\:\?\<\>\,\+\=\_\-\{\}\[\]\(\)\|\\\*\&\^%\$#\@\!\~\`\ ]/).empty?
      return false, "You can only use alpha numeric characters in your user name (a-z, 0-9)."
    end
    return true, "Name looks good."
  end
    
  def admin?
    return self.role == "Admin"
  end
  
  protected
  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{user_name}--") if new?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    crypted_password.blank? || !password.blank?
  end

end
