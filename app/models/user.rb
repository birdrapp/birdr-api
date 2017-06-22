class User < ApplicationRecord
  attr_accessor :password_reset_token

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

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def generate_password_reset_token
    self.password_reset_token = SecureRandom.urlsafe_base64 30
    update_attribute(:password_reset_digest, User.digest(password_reset_token))
    update_attribute(:password_reset_sent_at, Time.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
end
