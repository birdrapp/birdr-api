# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_reset
  def password_reset
    user = FactoryGirl.create :user
    user.generate_password_reset_token
    UserMailer.password_reset(user)
  end

end
