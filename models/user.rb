class User < ActiveRecord::Base
  validates :username, {
    :format => { :with => /[a-z][a-z0-9_]+/i },
    :presence => true,
    :uniqueness => true
  }

  def username=(val)
    write_attribute(:username, val.downcase)
  end

  has_many :catchphrases
  has_many :messages

end

