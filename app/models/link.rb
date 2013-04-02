class Link < ActiveRecord::Base
    belongs_to :user

    validates :url, presence: true
    validates :title, presence: true
    validates :datetime, presence: true
    validates :user_id, presence: true

    default_scope -> { order('datetime DESC') }
end
