require 'spec_helper'

feature "Welcome", %q{
  Shows empty page with login button
} do

  background do
    p User.all
  end

  scenario "Welcome index" do
    visit "/"
    page.should have_content("login")
  end

end
