class User < ActiveRecord::Base
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

    def get_new_links
        feed_url = "http://feeds.pinboard.in/rss/u:#{self.pinboard}/"
        feed = Feedzirra::Feed.fetch_and_parse(feed_url)
        if feed 
            add_new_links(feed.entries)
        end
    end

    private
        
        def create_remember_token
            self.remember_token = SecureRandom.urlsafe_base64
        end

        def add_new_links(entries)
            entries.each do |entry|
                link_id = entry.author + "@" + entry.published.to_s
                # Check if it already exists? Enforce uniqueness w/ index?
                self.links.create!(url: entry.url,
                                   title: entry.title,
                                   description: entry.summary,
                                   datetime: entry.published,
                                   link_id: link_id)
            end
        end
end
