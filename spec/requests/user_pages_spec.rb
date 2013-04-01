require 'spec_helper'

def new_user
    FactoryGirl.create(:user)
end

describe "UserPages" do
    subject { page }

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
                it { should have_selector('div.alert.alert-success', 
                                          text: 'Welcome') }
            end
        end
    end
end
