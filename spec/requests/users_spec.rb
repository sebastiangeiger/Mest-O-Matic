require 'spec_helper'

feature "Users", %q{
  In order to group users
  As a staff member
  I want to be able to assign unassigned users
} do


  background do
    Staff.create(:first_name => "Some", :last_name => "Fellow",  :identifier_url => "http://someidentifier.url/1234", :email => "some.fellow@meltwater.org")
    c = ClassOf.create(:year => 2022)
    Eit.create(  :first_name => "Some", :last_name => "Student", :identifier_url => "http://someidentifier.url/abdc", :email => "some.eit@meltwater.org", :class_of => c)
    User.create( :first_name => "New" , :last_name => "User",    :identifier_url => "http://someidentifier.url/efgh", :email => "some.user@meltwater.org")
  end

  scenario "Staff member logs in, assigns an unassigned user as eit, logs out, when the assigned user logs in he is identified as an Eit" do
    visit "/testlogin/1" #fake login
    visit "/users/unassigned_roles"
    page.should have_content("some.user@meltwater.org")
    select("Eit (Class of 2022)")
    find_button('Assign').click
    page.should have_content("No unassigned users at this time.")
    page.should have_content("Roles assigned")
    click_link "logout"
    visit "/testlogin/3"
    page.should have_content("New User is Eit")
  end

  scenario "Staff member logs in, assigns an unassigned user as eit, but leaves the second one unassigned, the next page still shows one unassigned user" do
    User.create( :first_name => "Second New" , :last_name => "User",    :identifier_url => "http://someidentifier.url/7689", :email => "somenew.user@meltwater.org")
    visit "/testlogin/1" #fake login
    visit "/users/unassigned_roles"
    page.should have_content("some.user@meltwater.org")
    page.should have_content("somenew.user@meltwater.org")
    select("Eit (Class of 2022)")
    find_button('Assign').click
    page.should have_content("somenew.user@meltwater.org")
    select("Eit (Class of 2022)")
    find_button('Assign').click
    page.should have_content("No unassigned users at this time.")
    page.should have_content("Roles assigned")
  end
end

feature "Users", %q{
  In order to have the right information displayed
  As an Eit
  I want to be able to edit my name
} do


  background do
    c = ClassOf.create(:year => 2022)
    Staff.create(:first_name => "Some",    :last_name => "Fellow",  :identifier_url => "http://someidentifier.url/1234", :email => "some.fellow@meltwater.org")
    Eit.create(  :first_name => "Some",    :last_name => "Student", :identifier_url => "http://someidentifier.url/abdc", :email => "some.eit@meltwater.org", :class_of => c)
    Eit.create(  :first_name => "Another", :last_name => "Student", :identifier_url => "http://someidentifier.url/efgh", :email => "another.user@meltwater.org", :class_of => c)
  end

  scenario "Eit logs in, goes to his profile, makes some changes and saves them" do
    visit "/testlogin/2" #fake login
    visit "/users/2/edit"
    fill_in "First Name", :with => "Named"
    fill_in "Last Name", :with => "Eit"
    find_button('save').click
    e = Eit.where(:id => 2).first
    e.first_name.should == "Named"
    e.last_name.should == "Eit"
  end

  scenario "Eit logs in, goes to somebody elses profile, gets redirected to his own" do
    visit "/testlogin/2" #fake login
    visit "/users/3/edit"
    current_url.should == "http://www.example.com/users/2/edit"
    page.should have_content("Not enough privileges to edit this user. Here is your profile")
  end
end

feature "Users", %q{
  In order to have the right information displayed
  As a Staff member
  I want to be able to edit any user and eit
} do


  background do
    c = ClassOf.create(:year => 2022)
    Staff.create(:first_name => "Some",    :last_name => "Fellow",  :identifier_url => "http://someidentifier.url/1234", :email => "some.fellow@meltwater.org")
    Eit.create(  :first_name => "Some",    :last_name => "Student", :identifier_url => "http://someidentifier.url/abdc", :email => "some.eit@meltwater.org", :class_of => c)
    Eit.create(  :first_name => "Another", :last_name => "Student", :identifier_url => "http://someidentifier.url/efgh", :email => "another.user@meltwater.org", :class_of => c)
    Staff.create(:first_name => "Another",    :last_name => "Fellow",  :identifier_url => "http://someidentifier.url/5678", :email => "another.fellow@meltwater.org")
  end

  scenario "Staff logs in, goes to his profile, makes some changes and saves them" do
    visit "/testlogin/1" #fake login
    visit "/users/1/edit"
    fill_in "First Name", :with => "I Am"
    fill_in "Last Name", :with => "A Fellow"
    find_button('save').click
    e = Staff.where(:id => 1).first
    e.first_name.should == "I Am"
    e.last_name.should == "A Fellow"
  end
  scenario "Staff logs in, goes to an User profile, makes some changes and saves them"
  scenario "Staff logs in, goes to an Eit  profile, makes some changes and saves them" 
  scenario "Staff logs in, goes to a Staff profile that is not his and gets turned away" 


end

