require 'spec_helper'

feature "Welcome", %q{
  Shows a link to projects page and a login button
} do

  scenario "Welcome index" do
    visit "/"
    page.should have_link("Assignments")
    page.should have_content("login")
  end

end
