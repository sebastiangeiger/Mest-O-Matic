require 'spec_helper'

describe User do
  it "should create a User with a first name, last name, identifier_url and a email address" do
    User.create(:first_name => "Max", :last_name => "Moore", :identifier_url => "http://someopenid.org/?identifier=123", :email => "max.moore@meltwater.org").should be_valid
  end

  it "should not create a User without a first name" do
    User.create(:last_name => "Moore", :identifier_url => "http://someopenid.org/?identifier=123", :email => "max.moore@meltwater.org").should_not be_valid
  end

  it "should create a User without a last name" do
    User.create(:first_name => "Max", :identifier_url => "http://someopenid.org/?identifier=123", :email => "max.moore@meltwater.org").should_not be_valid
  end

  it "should create a User without an identifier_url" do
    User.create(:first_name => "Max", :last_name => "Moore", :email => "max.moore@meltwater.org").should_not be_valid
  end

  it "should create a User without an email address" do
    User.create(:first_name => "Max", :last_name => "Moore", :identifier_url => "http://someopenid.org/?identifier=123").should_not be_valid
  end

  it "should not create a User with the same email address twice" do
    User.create(:first_name => "Max", :last_name => "Moore", :identifier_url => "http://someopenid.org/?identifier=123", :email => "max.moore@meltwater.org").should be_valid
    User.create(:first_name => "Maxis", :last_name => "Moor", :identifier_url => "http://someopenid.org/?identifier=321", :email => "max.moore@meltwater.org").should_not be_valid
  end

  it "should not create a User with the same identifier_url twice" do
    User.create(:first_name => "Max", :last_name => "Moore", :identifier_url => "http://someopenid.org/?identifier=123", :email => "max.moore@meltwater.org").should be_valid
    User.create(:first_name => "Maxis", :last_name => "Moor", :identifier_url => "http://someopenid.org/?identifier=123", :email => "maxis.moor@meltwater.org").should_not be_valid
  end

  it "should return the first part of the email address in capitalized form as suggested first name if no first name is present" do
    @user = User.new(:email => "max.moore@meltwater.org")
    @user.suggested_first_name.should be_eql("Max")
  end

  it "should return the second part of the email address in capitalized form as suggested last name if no last name is present" do
    @user = User.new(:email => "max.moore@meltwater.org")
    @user.suggested_last_name.should be_eql("Moore")
  end
  
  it "should not create a User with the first name starting in lower case" do
    User.create(:first_name => "max", :last_name => "Moore", :identifier_url => "http://someopenid.org/?identifier=123", :email => "max.moore@meltwater.org").should_not be_valid    
  end

  it "should not create a User with the first name starting in lower case" do
    User.create(:first_name => "Max", :last_name => "moore", :identifier_url => "http://someopenid.org/?identifier=123", :email => "max.moore@meltwater.org").should_not be_valid    
  end

  it "should not create a User with one of the middle names starting in lower case" do
    User.create(:middle_names => "some Middlename", :first_name => "Max", :last_name => "Moore", :identifier_url => "http://someopenid.org/?identifier=123", :email => "max.moore@meltwater.org").should_not be_valid    
  end

  it "should not create a User with one of the middle names starting in lower case" do
    User.create(:middle_names => "Some middlename", :first_name => "Max", :last_name => "Moore", :identifier_url => "http://someopenid.org/?identifier=123", :email => "max.moore@meltwater.org").should_not be_valid    
  end

end
