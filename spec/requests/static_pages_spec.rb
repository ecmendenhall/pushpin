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
            click_link "About"
            expect(page).to have_title(full_title('About'))
        end
    end

    describe "About page" do
        before { visit about_path }
        let(:heading) { 'About Pushpin' }
        let(:page_title) { 'About' }

        it_should_behave_like "all static pages"
    end


end
