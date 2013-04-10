class UserMailer < ActionMailer::Base
  include UsersHelper
  default from: "confirm@pushpin-prototype.com"

  def confirm_email(user)
      @user = user
      @url  = get_confirm_url(
              type: "email", 
              code: user.email_confirmation_code)
      mail(to: user.email, subject: "Confirm your Pushpin account")
  end
end
