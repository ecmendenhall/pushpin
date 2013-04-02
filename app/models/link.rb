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
    validates :title, presence: true
    validates :datetime, presence: true
    validates :user_id, presence: true

    default_scope -> { order('datetime DESC') }
end
