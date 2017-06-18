class User < ApplicationRecord
  before_save { email.downcase! }

  validates :first_name, presence: true, length: { maximum: 255 }
  validates  :last_name, presence: true, length: { maximum: 255 }
  validates      :email, presence: true,
                         length: { maximum: 255 },
                         uniqueness: { case_sensitive: false },
                         format: { with: /.+@.+\..+/ }

end
