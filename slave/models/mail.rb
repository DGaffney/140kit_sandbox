class Mail
  include DataMapper::Resource
  property :id, Serial
  property :sent, Boolean, :default => false
  property :message_content, Text
  property :recipient, Text
  property :subject, Text
  property :researcher_id, Integer, :index => [:researcher_id]
  belongs_to :researcher, :child_key => :researcher_id
  
  def self.queue(response)
    mail = Mail.new(response)
    mail.save if self.storage_exists? #since i'm too lazy to rake db:migrate right now...
    return mail
  end
end