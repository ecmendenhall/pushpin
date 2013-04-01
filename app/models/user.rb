class User < ActiveRecord::Base
    before_save { self.email = email.downcase }

    validates :name,  
        presence: true,
        length: { maximum: 50 }
    
    VALID_EMAIL_REGEX = /[\w+\-.]+@[a-z\d\-.]+\.[a-zA-Z]+/i
    validates :email,
        presence: true, 
        format: { with: VALID_EMAIL_REGEX },
        uniqueness: { case_sensitive: false }

    has_secure_password
    validates :password, length: { minimum: 8 }
    validates :password_confirmation, presence: true
end