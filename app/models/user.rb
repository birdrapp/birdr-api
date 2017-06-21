class User < ApplicationRecord
  before_save { email.downcase! }

  has_secure_password

  validates :first_name, presence: true, length: { maximum: 255 }
  validates  :last_name, presence: true, length: { maximum: 255 }
  validates   :password, presence: true, length: { minimum: 6 }, allow_nil: true
  validates      :email, presence: true,
                         length: { maximum: 255 },
                         uniqueness: { case_sensitive: false },
                         format: { with: /.+@.+\..+/ }

  has_many :tokens, dependent: :destroy

  def User.find_by_token(token)
    token = token.id if token.respond_to?(:id)
    User.select('users.*').joins(:tokens).find_by(tokens: { id: token })
  end
end
