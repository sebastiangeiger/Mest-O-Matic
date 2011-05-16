require 'spec_helper'

describe User do
  it "should return the first part of the email address in capitalized form as suggested first name if no first name is present" do
    @user = User.new(:email => "max.moore@meltwater.org")
    @user.suggested_first_name.should be_eql("Max")
  end

  it "should return the second part of the email address in capitalized form as suggested last name if no last name is present" do
    @user = User.new(:email => "max.moore@meltwater.org")
    @user.suggested_last_name.should be_eql("Moore")
  end

  it "should be complete with a first name and a last name" do
    @user = User.create(:identifier_url => "http://someopenid.org/?identifier=123", :email => "max.moore@meltwater.org")
    @user.first_name = "Max"
    @user.last_name = "Moore"
    @user.should be_complete
  end

  it "should not be complete without first name or last name" do
    @user = User.create(:identifier_url => "http://someopenid.org/?identifier=123", :email => "max.moore@meltwater.org")
    @user.should_not be_complete
  end

  it "should not be complete without a first name" do
    @user = User.create(:identifier_url => "http://someopenid.org/?identifier=123", :email => "max.moore@meltwater.org")
    @user.last_name = "Moore"
    @user.should_not be_complete
  end
  
  it "should not be complete without a last name" do
    @user = User.create(:identifier_url => "http://someopenid.org/?identifier=123", :email => "max.moore@meltwater.org")
    @user.first_name = "Max"
    @user.should_not be_complete
  end

  describe "CREATE" do
    it "should create a User with an identifier_url and an email address" do
      User.create(:identifier_url => "http://someopenid.org/?identifier=123", :email => "max.moore@meltwater.org").should be_valid(:create)
    end

    it "should create a User without an email address" do
      User.create(:identifier_url => "http://someopenid.org/?identifier=123").should_not be_valid
    end

    it "should create a User without an identifier_url" do
      User.create(:email => "max.moore@meltwater.org").should_not be_valid
    end

    it "should not create a User with the same email address twice" do
      User.create(:first_name => "Max", :last_name => "Moore", :identifier_url => "http://someopenid.org/?identifier=123", :email => "max.moore@meltwater.org").should be_valid
      User.create(:first_name => "Maxis", :last_name => "Moor", :identifier_url => "http://someopenid.org/?identifier=321", :email => "max.moore@meltwater.org").should_not be_valid
    end

    it "should not create a User with the same identifier_url twice" do
      User.create(:first_name => "Max", :last_name => "Moore", :identifier_url => "http://someopenid.org/?identifier=123", :email => "max.moore@meltwater.org").should be_valid
      User.create(:first_name => "Maxis", :last_name => "Moor", :identifier_url => "http://someopenid.org/?identifier=123", :email => "maxis.moor@meltwater.org").should_not be_valid
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

  describe "UPDATE" do
    before(:each) do
      @user = User.create(:identifier_url => "http://someopenid.org/?identifier=123", :email => "max.moore@meltwater.org")
      @user.should be_valid(:create)
      @user.should_not be_valid(:update)
    end
    
    it "should update a User with a first name, last name" do
      @user.first_name = "Max"
      @user.last_name = "Moore"
      @user.should be_valid
    end

    it "should update a User with a first name, a last name and middle names" do
      @user.first_name = "Max"
      @user.last_name = "Moore"
      @user.middle_names = "Middle Name"
      @user.should be_valid    
    end
    
    it "should NOT update a User without a last name" do
      @user.first_name = "Max"
      @user.should_not be_valid
    end

    it "should NOT update a User without a first name" do
      @user.last_name = "Moore"
      @user.should_not be_valid
    end

    it "should not update a User with the first name starting in lower case" do
      @user.first_name = "max"
      @user.last_name = "Moore"
      @user.should_not be_valid    
    end
    
    it "should not update a User with the last name starting in lower case" do
      @user.first_name = "Max"
      @user.last_name = "moore"
      @user.should_not be_valid    
    end
    
    it "should not update a User with one of the middle names starting in lower case" do
      @user.first_name = "Max"
      @user.last_name = "Moore"
      @user.middle_names = "Middle name"
      @user.should_not be_valid    
    end
    
    it "should not update a User with one of the middle names starting in lower case" do
      @user.first_name = "Max"
      @user.last_name = "Moore"
      @user.middle_names = "middle Name"
      @user.should_not be_valid    
    end
    
    it "should update a User with a first name, last name and the type Eit" do
      @user.first_name = "Max"
      @user.last_name = "Moore"
      @user.type = "Eit"
      @user.should be_valid
    end

    it "should update a User with a first name, last name and the type Staff" do
      @user.first_name = "Max"
      @user.last_name = "Moore"
      @user.type = "Staff"
      @user.should be_valid
    end    

    it "should update a User with a first name, last name and a type that is nil" do
      @user.first_name = "Max"
      @user.last_name = "Moore"
      @user.type = nil
      @user.should be_valid
    end    

    it "should not update a User with a first name, last name and a type that is not Eit or Staff" #do
      # @user.first_name = "Max"
      # @user.last_name = "Moore"
      # @user.type = "Nonsense"
      # @user.should_not be_valid
    # end    

  end
  
end
