class UserMailer < ActionMailer::Base
  default from: "confirm@pushpin-prototype.com"

  def confirm_email(user)
      if Rails.env.development?
          host = "localhost:3000"
      end
      @user = user
      @url  = Rails.application.routes.url_helpers.confirm_url( 
                type: "email", 
                code: user.email_confirmation_code,
                host: host)
      mail(to: user.email, subject: "Confirm your Pushpin account")
  end
end
