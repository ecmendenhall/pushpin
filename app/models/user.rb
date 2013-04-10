# == Schema Information
#
# Table name: users
#
#  id                         :integer          not null, primary key
#  name                       :string(255)
#  email                      :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#  password_digest            :string(255)
#  remember_token             :string(255)
#  admin                      :boolean          default(FALSE)
#  pinboard                   :string(255)
#  api_token                  :string(255)
#  pinboard_confirmed         :boolean
#  pinboard_confirmation_code :string(255)
#  email_confirmation_code    :string(255)
#  email_confirmed            :boolean
#

class User < ActiveRecord::Base
    before_create :create_confirmation_codes
    before_save { self.email = email.downcase }
    before_save :create_remember_token
    after_save :get_new_links

    has_many :comments, dependent: :destroy
    has_many :links, dependent: :destroy
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
  
    validates :pinboard, presence: true
    validates :api_token, presence: true

    def feed
        Link.from_users_followed_by(self)
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

    def get_new_links
        feed_url = "http://feeds.pinboard.in/rss/u:#{self.pinboard}/"
        feed = Feedzirra::Feed.fetch_and_parse(feed_url)
        if feed
            add_new_links(feed.entries)
        end
    end

    def new_confirm_code
        SecureRandom.urlsafe_base64(6)
    end

    private
        
        def create_remember_token
            self.remember_token = SecureRandom.urlsafe_base64
        end

        def create_confirmation_codes
            self.pinboard_confirmation_code = new_confirm_code
            self.email_confirmation_code = new_confirm_code
        end

        def add_new_links(entries)
            entries.each do |entry|
                existing_link = self.links.find_by_url entry.url
                if existing_link.nil?
                     self.links.create!(url: entry.url,
                                        title: entry.title,
                                        description: entry.summary,
                                        datetime: entry.published)
                end
            end
        end
end
