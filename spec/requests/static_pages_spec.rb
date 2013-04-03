require 'spec_helper'

describe "StaticPages" do
    subject { page }
    
    shared_examples_for "all static pages" do
        it { should have_content(heading) }
        it { should have_title(full_title(page_title)) }
    end

    describe "Home page" do
        before { visit root_path }
        let(:heading) { 'Pushpin' }
        let(:page_title) { '' }

        it_should_behave_like "all static pages" 
        it { should_not have_title(full_title('Home')) }
        it "should have the right links on the layout" do
            click_link "Help"
            expect(page).to have_title(full_title('Help'))
        end

        describe "for signed-in users" do
            let(:user) { new_user }
            before do
                FactoryGirl.create(:comment, user: user, content: "Foo")
                FactoryGirl.create(:comment, user: user, content: "Bar")
                sign_in user
                visit root_path
            end

            it "should render the user's feed" do
                user.feed.each do |item|
                    expect(page).to have_selector("li##{item.id}", text: item.content)
                end
            end

            describe "follower/following counts" do
                let(:other_user) { new_user }
                before do
                    other_user.follow!(user)
                    visit root_path
                end

                it { should have_link("following 0", href: following_user_path(user)) }
                it { should have_link("followers 1", href: followers_user_path(user)) }
            end
        end
    end

    describe "Help page" do
        before { visit help_path }
        let(:heading) { 'What is Pinboard' }
        let(:page_title) { 'Help' }

        it_should_behave_like "all static pages"
    end


end
