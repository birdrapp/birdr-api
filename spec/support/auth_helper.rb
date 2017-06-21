module AuthHelper

  def sign_in
    allow_any_instance_of(ApplicationController).to receive(:authenticate!).and_return(true)
  end

  def sign_in_as(user)
    sign_in
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  private

  def valid_user
    @valid_user ||= FactoryGirl.create :user
  end

end
