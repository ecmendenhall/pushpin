# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  content    :text
#  user_id    :integer
#  link_id    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Comment < ActiveRecord::Base
    belongs_to :user
    belongs_to :link
    default_scope -> { order('created_at DESC') }

    validates :user_id, presence: true
    validates :link_id, presence: true
    validates :content, presence: true

end
