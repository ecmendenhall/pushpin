# == Schema Information
#
# Table name: links
#
#  id          :integer          not null, primary key
#  url         :string(255)
#  title       :string(255)
#  description :text
#  datetime    :datetime
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Link < ActiveRecord::Base
    belongs_to :user
    has_many :comments

    validates :url, presence: true
    validates_uniqueness_of :url, scope: :user_id
    validates :title, presence: true
    validates :datetime, presence: true
    validates :user_id, presence: true

    default_scope -> { order('datetime DESC') }

    def self.from_users_followed_by(user)
        followed_user_ids = "SELECT followed_id FROM relationships
                             WHERE follower_id = :user_id"
        where("user_id IN (#{followed_user_ids}) OR user_id = :user_id",
               user_id: user.id)
    end
end
