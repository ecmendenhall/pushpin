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
  
                describe "visiting a user page" do
                    before { visit user_path(user) }
                    it { should have_title('Sign in') }
                end

                describe "visiting a user links page" do
                    before { visit links_user_path(user) }
                    it { should have_title('Sign in') }
                end

                describe "visiting a user comments page" do
                    before { visit comments_user_path(user) }
                    it { should have_title('Sign in') }
                end 
        
                describe "visiting the following page" do
                    before { visit following_user_path(user) }
                    it { should have_title('Sign in') }
                end

                describe "visiting the followers page" do
                    before { visit followers_user_path(user) }
                    it { should have_title('Sign in') }
                end
            end

            describe "in the Comments controller" do

                describe "submitting to the create action" do
                    before { post comments_path }
                    specify { expect(response).to redirect_to(signin_path) }
                end

                describe "submitting to the destroy action" do
                    before { delete comment_path(FactoryGirl.create(:comment)) }
                    specify { expect(response).to redirect_to(signin_path) }
                end
            end

            describe "in the Relationships controller" do
                describe "submitting to the create action" do
                    before { post relationships_path }
                    specify { expect(response).to redirect_to(signin_path) }
                end

                describe "submitting to the destroy action" do
                    before { delete relationship_path(1) }
                    specify { expect(response).to redirect_to(signin_path) }
                end
            end

            describe "in the Links controller" do
                let(:link) { FactoryGirl.create(:link) }

                describe "visiting a link page" do
                    before { visit link_path(link) }
                   it { should have_title("Sign in") }
                end
        
                describe "sharing a link" do
                    before { get share_link_path(link) }
                    specify { expect(response).to redirect_to(signin_path) }
                end
        
                describe "saving a link" do
                    before { get save_link_path(link) }
                    specify { expect(response).to redirect_to(signin_path) }
                end
        
                describe "adding a comment" do
                    before { visit new_comment_link_path(link) }
                    it { should have_title("Sign in") }
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

    
        describe "for inactive users" do
            let(:user) { new_user }

            before do
                user.email_confirmed = false
                user.pinboard_confirmed = false
                user.save
                sign_in user
            end
                
            describe "in the Users controller" do

                describe "visiting the edit page" do
                    before { visit edit_user_path(user) }
                    it { should have_title("Edit") }
                end

                describe "submitting to the edit page" do 
                    describe "updating email" do
                        before do
                            visit edit_user_path(user)
                            fill_in "Email", with: "a@b.biz"
                            click_button "Save changes"
                        end

                        it { should have_title('Pushpin') }
                        it { should have_selector('div.alert.alert-success',                                                                    text:'Sent a new confirmation email') }
                    end
            
                    describe "updating pinboard" do
                        before do
                            visit edit_user_path(user)
                            fill_in "Pinboard username", with: "reggie87"
                            click_button "Save changes"
                        end

                        it { should have_title('Pushpin') }
                        it { should have_selector('div.alert.alert-success',
                                                  text:'Saved a new confirmation link') }
                    end
                end        


                describe "visiting the user index" do
                    before { visit users_path }
                    it { should have_title('Confirm your account') }
                end
  
                describe "visiting a user page" do
                    before { visit user_path(user) }
                    it { should have_title('Confirm your account') }
                end

                describe "visiting a user comments page" do
                    before { visit comments_user_path(user) }
                    it { should have_title('Confirm your account') }
                end 
        
                describe "visiting the following page" do
                    before { visit following_user_path(user) }
                    it { should have_title('Confirm your account') }
                end

                describe "visiting the followers page" do
                    before { visit followers_user_path(user) }
                    it { should have_title('Confirm your account') }
                end
            end

            describe "in the Comments controller" do

                describe "submitting to the create action" do
                    before { post comments_path }
                    specify { expect(response).to redirect_to(confirm_status_user_path(user)) }
                end

                describe "submitting to the destroy action" do
                    before { delete comment_path(FactoryGirl.create(:comment)) }
                    specify { expect(response).to redirect_to(confirm_status_user_path(user)) }
                end
            end

            describe "in the Relationships controller" do
                describe "submitting to the create action" do
                    before { post relationships_path }
                    specify { expect(response).to redirect_to(confirm_status_user_path(user)) }
                end

                describe "submitting to the destroy action" do
                    before { delete relationship_path(1) }
                    specify { expect(response).to redirect_to(confirm_status_user_path(user)) }
                end
            end

            describe "in the Links controller" do
                let(:link) { FactoryGirl.create(:link) }

                describe "visiting a link page" do
                    before { visit link_path(link) }
                    it {should have_title("Confirm your account") }
                end
        
                describe "sharing a link" do
                    before { get share_link_path(link) }
                    specify { expect(response).to redirect_to(confirm_status_user_path(user)) }
                end
        
                describe "saving a link" do
                    before { get save_link_path(link) }
                    specify { expect(response).to redirect_to(confirm_status_user_path(user)) }
                end
        
                describe "adding a comment" do
                    before { visit new_comment_link_path(link) }
                    it {should have_title("Confirm your account") }
                end
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

            describe "visiting another user's account confirmation status page " do
                before { visit confirm_status_user_path(wrong_user) }
                it { should_not have_content("wrong@email.com") }
            end
        end
    end
end
