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
        before { visit user_path(user) }

        it { should have_content(user.name) }
        it { should have_title(user.name) }
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
                fill_in "Password",         with: "beatrice"
                fill_in "Confirm password", with: "beatrice"
            end

            it "should create a user" do
                expect { click_button submit }.to change(User, :count).by(1)
            end

            describe "after saving the user" do
                before { click_button submit }
                let(:user) { User.find_by(email: "beatrice@fw.com") }

                it { should have_title(user.name) }
                it { should have_link('Sign out') }
                it { should have_selector('div.alert.alert-success', 
                                          text: 'Welcome') }
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
            it { should have_content("Update your profile") }
            it { should have_title("Edit user") }
            it { should have_link("change", href: "http://gravatar.com/emails") }
        end

        describe "with invalid information" do
            before { click_button "Save changes" }
            it { should have_content("error") }
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
            end

            it { should have_title(new_name) }
            it { should have_selector('div.alert.alert-success') }
            it { should have_link('Sign out', href: signout_path) }
            specify { expect(user.reload.name).to  eql(new_name) }
            specify { expect(user.reload.email).to eql(new_email) }
        end
    end
end
