# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  content    :text
#  user_id    :integer
#  link_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Comment do
    let(:user) { new_user }
    before do
        @comment = user.comments.build(content: "Wow, cool link!",
                                       link_id: "user@2013-03-27T22:23:11Z")
    end

    subject { @comment }

    it { should respond_to(:content) }
    it { should respond_to(:user_id) }
    it { should respond_to(:link_id) }

    it { should be_valid }

    describe "when content is empty" do
        before { @comment.content = "" } 
        it { should_not be_valid }
    end

    describe "when user_id is not present" do
        before { @comment.user_id = nil } 
        it { should_not be_valid }
    end

    describe "when link_it is not present" do
        before { @comment.user_id = nil }
        it { should_not be_valid }
    end
end
