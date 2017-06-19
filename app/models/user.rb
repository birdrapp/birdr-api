class User < ApplicationRecord
  before_save { email.downcase! }

  has_secure_password

  validates :first_name, presence: true, length: { maximum: 255 }
  validates  :last_name, presence: true, length: { maximum: 255 }
  validates   :password, presence: true, length: { minimum: 6 }
  validates      :email, presence: true,
                         length: { maximum: 255 },
                         uniqueness: { case_sensitive: false },
                         format: { with: /.+@.+\..+/ }

  has_many :tokens
end
