require 'spec_helper'

describe "Authentication" do
    subject { page }

    describe "signin page" do
        before { visit signin_path }

        it { should have_content('Sign in') }
        it { should have_title('Sign in') }
    end

    describe "signin" do
        before { visit signin_path }
        
        describe "with invalid information" do
            before { click_button "Sign in" }

            it { should have_title('Sign in') }
            it { should have_selector('div.alert.alert-error', text: 'Invalid') }

            describe "after visiting another page" do
                before { click_link "Pushpin" }
                it { should_not have_selector('div.aler.alert-error') }
            end
        end

        describe "with valid information" do
            let(:user) { new_user }
            before do
                fill_in "Email",    with: user.email.upcase
                fill_in "Password", with: user.password
                click_button "Sign in"
            end

            it { should have_title(user.name) }
            it { should have_link('Users',       href: users_path) }
            it { should have_link('Profile',     href: user_path(user)) }
            it { should have_link('Sign out',    href: signout_path) }
            it { should_not have_link('Sign in', href: signin_path) }

            describe "followed by signout" do
                before { click_link "Sign out" }
                it { should have_link('Sign in') }
            end
        end
    end

    describe "authorization" do
        describe "for non-signed-in users" do
            let(:user) { new_user }

            describe "in the Users controller" do

                describe "visiting the edit page" do
                    before { visit edit_user_path(user) }
                    it { should have_title("Sign in") }
                end

                describe "submitting to the update action" do
                    before { patch user_path(user) }
                    specify { expect(response).to redirect_to(signin_path) }
                end

                describe "visiting the user index" do
                    before { visit users_path }
                    it { should have_title('Sign in') }
                end
            end
        end

        describe "as non-admin user" do
            let(:user) { new_user }
            let(:non_admin) { new_user }

            before { sign_in non_admin }

            describe "submitting a DELETE request to Users#destroy" do
                before { delete user_path(user) }
                specify { expect(response).to redirect_to(root_path) }
            end
        end

        describe "as wrong user" do
            let(:user) { new_user }
            let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@email.com") }
            before { sign_in user }

            describe "visiting Users#edit" do
                before { visit edit_user_path(wrong_user) }
                it { should_not have_title(full_title('Edit user')) }
            end

            describe "submitting a PATCH request to Users#update" do
                before { patch user_path(wrong_user) }
                specify { expect(response).to redirect_to(root_path) }
            end
        end
    end
end
