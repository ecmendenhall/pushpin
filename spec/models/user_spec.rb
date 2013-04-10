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

require 'spec_helper'

describe User do
    
    before { @user = User.new(name: "Beatrice Fastwater", 
                              email: "beatrice@fw.info",
                              pinboard: "beatrice",
                              api_token: "beatrice:1234567890",
                              password: "beatrice",
                              password_confirmation: "beatrice") }
    subject { @user }

    it { should respond_to(:name) }
    it { should respond_to(:email) }

    it { should respond_to(:pinboard) }
    it { should respond_to(:api_token) }

    it { should respond_to(:password_digest) }
    it { should respond_to(:password) }
    it { should respond_to(:password_confirmation) }

    it { should respond_to(:remember_token) }
    it { should respond_to(:authenticate) }

    it { should respond_to(:admin) }

    it { should respond_to(:comments) }
    it { should respond_to(:feed) }

    it { should respond_to(:relationships) }
    it { should respond_to(:reverse_relationships) }
    it { should respond_to(:followers) }
    it { should respond_to(:followed_users) }
    it { should respond_to(:following?) }
    it { should respond_to(:follow!) }

    it { should respond_to(:links) }

    it { should be_valid }
    it { should_not be_admin }

    describe "following" do
        let(:other_user) { new_user }
        before do
            @user.save
            @user.follow!(other_user)
        end

        it { should be_following(other_user) }
        its(:followed_users) { should include(other_user) }

        describe "followed user" do
            subject { other_user }
            its(:followers) { should include(@user) }
        end

        describe "and unfollowing" do
            before { @user.unfollow!(other_user) }
            it { should_not be_following(other_user) }
            its(:followed_users) { should_not include(other_user) }
        end
    end

    describe "with admin attribute set to 'true'" do
        before do
            @user.save!
            @user.toggle!(:admin)
        end

        it { should be_admin }
    end

    describe "remember token" do
        before { @user.save }
        its(:remember_token) { should_not be_blank }
    end

    describe "when name is not present" do
        before { @user.name = " " }
        it { should_not be_valid }
    end

    describe "when email is not present" do
        before { @user.email = " " }
        it { should_not be_valid }
    end

    describe "when name is too long" do
        before { @user.name = "a" * 51 }
        it { should_not be_valid }
    end

    describe "when email format is invalid" do
        it "should be invalid" do
            addresses = %w[user@foo,com
                           user_at_foo.org
                           example.user@foo.
                           foo@bar_baz.com
                           foo@bar+baz.com]

            addresses.each do |invalid_email|
                @user.email = invalid_email
                expect(@user).not_to be_valid
            end
        end
    end

    describe "when email format is valid" do
        it "should be valid" do
            addresses = %w[user@foo.COM
                           A_US-ER@f.b.org
                           frst.lst@foo.jp
                           a+b@baz.cn]

            addresses.each do |valid_email|
                @user.email = valid_email
                expect(@user).to be_valid
            end
        end
    end

    describe "when email address is already taken" do
        before do
            user_with_same_email = @user.dup
            user_with_same_email.email = @user.email.upcase
            user_with_same_email.save
        end

        it { should_not be_valid }
    end

    describe "when password is not present" do
        before { @user.password = @user.password_confirmation = " " }
        it { should_not be_valid }
    end

    describe "when password and confirmation don't match" do
        before { @user.password_confirmation = "mismatch" }
        it { should_not be_valid }
    end

    describe "when password confirmation is nil" do
        before { @user.password_confirmation = nil }
        it { should_not be_valid }
    end

    describe "with a password that's too short" do
        before { @user.password = @user.password_confirmation = "a" * 5 }
        it { should be_invalid }
    end

    describe "return value of authenticate method" do
        before { @user.save }
        let(:found_user) { User.find_by(email: @user.email) }

        describe "with valid password" do
            it { should eql(found_user.authenticate(@user.password)) }
        end

        describe "with invalid password" do
            let(:user_with_invalid_password) { found_user.authenticate("invalid") }
            it { should_not eql(user_with_invalid_password) }
            specify { expect(user_with_invalid_password).to be_false }
        end
    end

    describe "link associations" do
        before { @user.save }
        let!(:older_link) do
            FactoryGirl.create(:link, user: @user,
                                      datetime: "2013-03-21T03:02:07Z".to_time)
        end
        let!(:newer_link) do
            FactoryGirl.create(:link, user: @user,
                                         datetime: "2013-03-22T03:02:07Z".to_time)
        end
        it "should have the right links in the right order" do
            expect(@user.links.to_a).to eql([newer_link, older_link])
        end

        it "should destroy associated links" do
            links = @user.links.dup.to_a
            @user.destroy
            expect(links).not_to be_empty
            links.each do |link|
                expect(Link.where(id: link.id)).to be_empty
            end
        end

        describe "status" do
            let(:unfollowed_link) do
                FactoryGirl.create(:link, user: new_user)
            end
            let(:followed_user) { new_user }

            before do
                @user.follow!(followed_user)
                3.times { followed_user.links.create!(title: "Lorem ipsum",
                                                      url: "http://example.com",
                                                      datetime: "2013-03-22T03:02:07Z".to_time) }
            end

            its(:feed) { should include(newer_link) }
            its(:feed) { should include(older_link) }
            its(:feed) { should_not include(unfollowed_link) }
            its(:feed) do
                followed_user.links.each do |link|
                    should include(link)
                end
            end
        end
    end

    describe "comment associations" do
        before { @user.save }
        let!(:older_comment) do
            FactoryGirl.create(:comment, user: @user,
                                         created_at: 1.day.ago)
        end
        let!(:newer_comment) do
            FactoryGirl.create(:comment, user: @user,
                                         created_at: 1.hour.ago)
        end
        it "should have the right comments in the right order" do
            expect(@user.comments.to_a).to eql([older_comment, newer_comment])
        end

        it "should destroy associated comments" do
            comments = @user.comments.dup.to_a
            @user.destroy
            expect(comments).not_to be_empty
            comments.each do |comment|
                expect(Comment.where(id: comment.id)).to be_empty
            end
        end
    end

    describe "fetching links" do
        @user = User.new(name: "Maciej", 
                         email: "maciej@pinboard.in",
                         pinboard: "maciej",
                         api_token: "maciej:120318927",
                         password: "pinboard",
                         password_confirmation: "pinboard",
                         pinboard: "maciej")
        @user.save
        maciej = User.find_by_email("maciej@pinboard.in")
        links = maciej.links
        specify { expect(links.count).to eql(70) }
    end
end
