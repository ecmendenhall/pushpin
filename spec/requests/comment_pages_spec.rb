require 'spec_helper'

describe "Comment pages" do

  subject { page }

  let(:user) { new_user }
  before { sign_in user }
  let(:link) { FactoryGirl.create(:link) }

  describe "comment creation" do
    before do
        visit new_comment_link_path(link)
    end

    describe "with invalid information" do

      it "should not create a comment" do
        expect { click_button "Post" }.not_to change(Comment, :count)
      end

      describe "error messages" do
        before { click_button "Post" }
        it { should have_content('Your comment could not be saved.') } 
      end
    end

    describe "with valid information" do

      before { fill_in 'comment_content', with: "Lorem ipsum" }
      it "should create a comment" do
        expect { click_button "Post" }.to change(Comment, :count).by(1)
      end
    end

    describe "with markdown" do
      before do
        fill_in 'comment_content', with: "*emphasis* [link](http://example.com)\
                                          __strong__ ~~strikethrough~~"
        click_button "Post"
        visit link_path(link)
      end

        it { should have_selector('em', text: "emphasis") }
        it { should have_selector('a', text: "link") }
        it { should have_selector('strong', text: "strong") }
        it { should have_selector('del', text: "strikethrough") }
    end
  end

  describe "comment destruction" do
      before do 
          link = FactoryGirl.create(:link, user: user)
          comment = FactoryGirl.create(:comment, user: user, link: link)
      end

      describe "as correct user" do
          before { visit root_path }

          it "should delete a comment" do
              expect { click_link "delete" }.to change(Comment, :count).by(-1)
          end
      end
  end
end
