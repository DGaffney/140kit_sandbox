class Researcher < Model
  include DataMapper::Resource
  property :id, Serial
  property :user_name, String
  property :email, Text, :default => "user@localhost.com"
  property :reset_code, String
  property :role, String, :default => "Admin"
  property :join_date, Time
  property :last_login, Time
  property :last_access, Time
  property :info, Text, :default => "I like to study the internet"
  property :website_url, Text, :default => "http://140kit.com/"
  property :location, String, :default => "The Internet"
  property :salt, String
  property :remember_token, String
  property :remember_token_expires_at, Time
  property :crypted_password, String
  property :share_email, Boolean, :default => false
  property :private_data, Boolean, :default => false
  property :hidden_account, Boolean, :default => false
  property :rate_limited, Boolean, :default => false
  attr_accessor :password
  
  def self.authenticate(user_name, password)
    u = find_by_user_name(user_name) # need to get the salt
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
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def set_times
    self.last_login = Time.now
    self.last_access = Time.now
    self.remember_token_expires_at = 2.weeks.from_now.utc
  end
  
  def set_join_date
    self.join_date = Time.now
  end
  
  def validate_on_create
    if !self.user_name.scan(/[\.\;\:\?\<\>\,\+\=\_\-\{\}\[\]\(\)\|\\\*\&\^%\$#\@\!\~\`]/).empty?
      return false, "You can only use alpha numeric characters in your user name (a-z, 0-9)."
    end
    return true, "Name looks good."
  end
  
  def create_reset_code
    self.reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    save(false)
  end

  def delete_reset_code
    self.reset_code = nil
    save(false)
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
  
  def after_destroy 
    if Researcher.count.zero? 
      raise "Can't delete last researcher" 
    end 
  end

end
