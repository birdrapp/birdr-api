require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "password reset" do
    let(:user) { FactoryGirl.create :user }
    let(:mail) { UserMailer.password_reset(user) }

    it "renders the headers" do
      expect(mail.subject).to eq("Password reset instructions")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["noreply@birdr.co.uk"])
    end

    it "includes the reset token" do
      expect(mail.body.encoded).to include(user.password_reset_token)
    end

    it "includes the users email address" do
      expect(mail.body.encoded).to include(CGI.escape(user.email))
    end
  end

end
