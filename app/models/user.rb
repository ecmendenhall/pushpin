class User < ActiveRecord::Base
    before_save { self.email = email.downcase }
    before_save :create_remember_token

    has_many :comments, dependent: :destroy
    has_many :relationships, 
        foreign_key: "follower_id", 
        dependent: :destroy
    has_many :reverse_relationships,
        foreign_key: "followed_id",
        class_name: "Relationship",
        dependent: :destroy
    has_many :followers,
        through: :reverse_relationships,
        source: :follower
    has_many :followed_users, 
        through: :relationships,
        source: :followed

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

    def feed
        end

    def following?(other_user)
        relationships.find_by(followed_id: other_user.id)
    end

    def follow!(other_user)
        relationships.create!(followed_id: other_user.id)
    end

    def unfollow!(other_user)
        relationships.find_by(followed_id: other_user.id).destroy
    end

    private
        
        def create_remember_token
            self.remember_token = SecureRandom.urlsafe_base64
        end
end
