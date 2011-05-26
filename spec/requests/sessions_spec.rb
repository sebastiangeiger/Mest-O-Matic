require 'spec_helper'

feature "Sessions", %q{
  In order to differentiate between users
  As a user of the site
  I want to be able to login
} do


  background do
    Staff.create(:first_name => "Some", :last_name => "Fellow",  :identifier_url => "http://someidentifier.url/1234", :email => "some.fellow@meltwater.org")
    c = ClassOf.create(:year => 2022)
    Eit.create(  :first_name => "Some", :last_name => "Student", :identifier_url => "http://someidentifier.url/abdc", :email => "some.eit@meltwater.org", :class_of => c)
  end

  scenario "login as staff" do
    visit '/'
    page.should have_content('login')
    visit "/testlogin/1" #fake login
    page.should have_content('Some Fellow is Staff')
    page.should have_content('logout')
  end

  scenario "login as eit" do
    visit '/'
    page.should have_content('login')
    visit "/testlogin/2" #fake login
    page.should have_content('Some Student is Eit')
    page.should have_content('logout')
  end
  
  scenario "login as eit, logout and login as fellow" do
    visit '/'
    page.should have_content('login')
    visit "/testlogin/2" #fake login
    page.should have_content('Some Student is Eit')
    click_link 'logout'
    page.should have_content('login')
    visit "/testlogin/1" #fake login
    page.should have_content('Some Fellow is Staff')
  end
  
end
