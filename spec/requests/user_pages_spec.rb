require 'spec_helper'

describe "UserPages" do
    subject { page }

    describe "index" do
        before do
            sign_in new_user
            FactoryGirl.create(:user, name: "Reginald Hornstein", 
                                      email: "reggie@gmail.com")
            FactoryGirl.create(:user, name: "Umberto H. MacGillicuddy",
                                      email: "uhm@website.museum")
            visit users_path
        end

        it { should have_title('All users') }
        it { should have_content('All users') }

        it "should list each user" do
            User.all.each do |user|
                expect(page).to have_selector('li', text: user.name)
            end
        end

        describe "pagination" do
            before(:all) { 30.times { new_user } }
            after(:all)  { User.delete_all }

            it { should have_selector('div.pagination') }

            it "should list each user" do
                User.paginate(page: 1).each do |user|
                    expect(page).to have_selector('li', text: user.name)
                end
            end
        end

        describe "delete links" do

            it { should_not have_link('delete') }

            describe "as an admin user" do
                let(:admin) { FactoryGirl.create(:admin) }
                before do
                    User.delete_all
                    new_user
                    sign_in admin
                    visit users_path
                end

                it { should have_link('delete', href: user_path(User.first)) }
                it "should be able to delete another user" do
                    expect { click_link('delete') }.to change(User, :count).by(-1)
                end
                it { should_not have_link('delete', href: user_path(admin)) }
            end
        end
    end

    describe "signup page" do
        before { visit signup_path }
        it { should have_content('Sign up') }
        it { should have_title(full_title('Sign up')) }
    end

    describe "profile page" do
        let(:user) { new_user }
        let!(:l1) { FactoryGirl.create(:link, user: user) }
        let!(:l2) { FactoryGirl.create(:link, user: user) }

        before do
            visit confirm_path(:email, user.email_confirmation_code)
            fill_in "Email", with: user.email
            fill_in "Password", with: user.password
            click_button "Sign in"

            visit confirm_path(:pinboard, user.pinboard_confirmation_code)
            fill_in "Email", with: user.email
            fill_in "Password", with: user.password
            click_button "Sign in"
            visit user_path(user)
        end

        it { should have_content(user.name) }
        it { should have_title(user.name) }

        describe "links" do
            it { should have_content(l1.title) }
            it { should have_content(l2.title) }
            it { should have_content(user.links.count) }
        end

        describe "follow/unfollow buttons" do
            let(:other_user) { new_user }
            before { sign_in user }

            describe "following a user" do
                before { visit user_path(other_user) }

                it "should increment the followed user count" do
                    expect do
                        click_button "Follow"
                    end.to change(user.followed_users, :count).by(1)
                end

                it "should increment the other user's followers count" do
                    expect do
                        click_button "Follow"
                    end.to change(other_user.followers, :count).by(1)
                end

                describe "toggling the button" do
                    before { click_button "Follow" }
                    it { should have_xpath("//input[@value='Unfollow']") }
                end
            end

            describe "unfollowing a user" do
                before do
                    user.follow!(other_user)
                    visit user_path(other_user)
                end

                it "should decrement the followed user count" do
                    expect do
                        click_button "Unfollow"
                    end.to change(user.followed_users, :count).by(-1)
                end

                it "should decrement the other user's followers count" do
                    expect do
                        click_button "Unfollow"
                    end.to change(other_user.followers, :count).by(-1)
                end

                describe "toggling the button" do
                    before { click_button "Unfollow" }
                    it { should have_xpath("//input[@value='Follow']") }
                end
            end
        end
    end

    describe "signup page" do
        before { visit signup_path }
        let(:submit) { "Sign up" }

        describe "with invalid information" do
            it "should not create a user" do
                expect { click_button submit }.not_to change(User, :count)
            end
            
            describe "after submission" do
                before { click_button submit }
                it { should have_title('Sign up') }
                it { should have_content('error') }
            end
        end

        describe "with valid information" do
            before do
                fill_in "Name",             with: "Beatrice Fastwater"
                fill_in "Email",            with: "beatrice@fw.com"
                fill_in "Pinboard username", with: "beatrice"
                fill_in "Pinboard API token", with: "beatrice:1234567890"
                fill_in "Password",         with: "beatrice"
                fill_in "Confirm password", with: "beatrice"
            end

            it "should create a user" do
                expect { click_button submit }.to change(User, :count).by(1)
            end

            describe "after saving the user" do
                before do
                    click_button submit
                end
                
                #it { should have_selector('div.alert.alert-success', 
                #                          text: 'Welcome') }

                before do
                    user = User.find_by(email: "beatrice@fw.com")

                    visit confirm_path(:email, user.email_confirmation_code)
                    fill_in "Email", with: user.email
                    fill_in "Password", with: user.password
                    click_button "Sign in"
        
                    visit confirm_path(:pinboard, user.pinboard_confirmation_code)
                    fill_in "Email", with: user.email
                    fill_in "Password", with: user.password
                    click_button "Sign in"
                    visit user_path(user)
                end
                it { should have_title('Confirm') }
                it { should have_link('Sign out') }
            end
        end
    end

    describe "edit" do
        let(:user) { new_user }
        before do
            sign_in user
            visit edit_user_path(user)
        end

        describe "page" do
            it { should have_content("Settings") }
            it { should have_title("Edit user") }
            it { should have_link("change", href: "http://gravatar.com/emails") }
        end

        describe "with invalid information" do
            before { click_button "Save changes" }
            it { should have_content("errors") }
        end

        describe "with valid information" do
            let(:new_name)  { "Reginald Hornstein" }
            let(:new_email) { "reggie@gmail.com" }
            before do
                fill_in "Name",             with: new_name
                fill_in "Email",            with: new_email
                fill_in "Password",         with: user.password
                fill_in "Confirm password", with: user.password
                click_button "Save changes"
        
                visit confirm_path(:email, user.email_confirmation_code)
                fill_in "Email", with: new_email
                fill_in "Password", with: user.password
                click_button "Sign in"
            end

            it { should have_title('Pushpin') }
            # it { should have_link('Sign out', href: signout_path) }
            specify { expect(user.reload.name).to  eql(new_name) }
            specify { expect(user.reload.email).to eql(new_email) }
        end
    end

    describe "following/followers" do
        let(:user) { new_user }
        let(:other_user) { new_user }
        before { user.follow!(other_user) }

        describe "followed users" do
            before do
                sign_in user
                visit following_user_path(user)
            end

            it { should have_title(full_title('Following')) }
            it { should have_selector('h3', text: 'Following') }
            it { should have_link(other_user.name, href: user_path(other_user)) }
        end

        describe "followers" do
            before do
                sign_in other_user
                visit followers_user_path(other_user)
            end

            it { should have_title(full_title('Followers')) }
            it { should have_selector('h3', text: 'Followers') }
            it { should have_link(user.name, href: user_path(user)) }
        end
    end 
end
