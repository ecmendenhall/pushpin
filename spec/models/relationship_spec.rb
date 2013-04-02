# == Schema Information
#
# Table name: relationships
#
#  id          :integer          not null, primary key
#  follower_id :integer
#  followed_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

require 'spec_helper'

describe Relationship do

    let(:follower) { new_user }
    let(:followed) { new_user }
    let(:relationship) { follower.relationships.build(followed_id: followed.id) }

    subject { relationship }
    it { should be_valid }

    describe "follower methods" do
        it { should respond_to(:follower) }
        it { should respond_to(:followed) }
        its(:follower) { should eql(follower) }
        its(:followed) { should eql(followed) }
    end

    describe "when followed id is missing" do
        before { relationship.followed_id = nil }
        it { should_not be_valid }
    end

    describe "when follower id is missing" do
        before { relationship.follower_id = nil }
        it { should_not be_valid }
    end
end
