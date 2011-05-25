require 'acceptance/acceptance_helper'

feature "Welcome", %q{
  Shows empty page with login button
} do

  background do
  end

  scenario "Welcome index" do
    visit "/"
    page.should have_content('login')
  end

end