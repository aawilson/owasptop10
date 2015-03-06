class User < ActiveRecord::Base
  validates :username, {
    :format => { :with => /[a-z][a-z0-9_]+/i },
    :presence => true,
    :uniqueness => true
  }

  def username= val
    write_attribute(:username, val.downcase)
  end

  def is_allowed_to_see_messages_for other_user
    other_user.id == self.id
  end

  has_many :catchphrases
  has_many :messages

end

