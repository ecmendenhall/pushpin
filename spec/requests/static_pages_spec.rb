require 'spec_helper'

describe "StaticPages" do
    describe "Home page" do
        before { visit root_path }
        subject { page }

        it { should have_content('Pushpin') }
        it { should have_title(full_title('')) }
        it { should_not have_title(full_title('Home')) }
    end

    describe "About page" do
        before { visit about_path }
        subject { page }

        it { should have_title(full_title('About')) }
        it { should have_content('About Pushpin') }
    end
end
