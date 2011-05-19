require 'spec_helper'

describe Eit do
  it "should have the type column eit after creation" do
    @eit = Eit.new()
    @eit.type.should be_eql("Eit")
  end
  
  it "should create an Eit that has a connection to a class" do
    class_of = ClassOf.new(:year => 2020)
    class_of.stubs(:id).returns(23)
    Eit.create(:first_name => "Max", :last_name => "Moore", :identifier_url => "http://someopenid.org/?identifier=123", :email => "max.moore@meltwater.org", :class_of => class_of).should be_valid
  end

  it "should not create an Eit that has no connection to a class" do
    Eit.create(:first_name => "Max", :last_name => "Moore", :identifier_url => "http://someopenid.org/?identifier=123", :email => "max.moore@meltwater.org").should_not be_valid
  end

end
