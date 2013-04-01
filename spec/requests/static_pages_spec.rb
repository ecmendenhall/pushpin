require 'spec_helper'

describe "StaticPages" do
    describe "Home page" do

        it "should have the content 'Pushpin'" do
            visit '/static_pages/home'
            expect(page).to have_content('Pushpin')
        end

        it "should have the base title" do
            visit '/static_pages/home'
            expect(page).to have_title('Pushpin')
        end

        it "should not have a custom title" do
            visit '/static_pages/home'
            expect(page).not_to have_title('| Home')
        end
    end

    describe "About page" do

        it "should have the right title" do
            visit '/static_pages/about'
            expect(page).to have_title('Pushpin | About')
        end

        it "should have the content 'About Pushpin'" do
            visit '/static_pages/about'
            expect(page).to have_content('About Pushpin')
        end
    end
end
