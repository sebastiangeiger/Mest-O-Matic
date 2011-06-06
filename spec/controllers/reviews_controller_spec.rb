require 'spec_helper'

describe ReviewsController do

  describe "GET 'index'" do
    before(:each) do
      @deliverable = Deliverable.new
      Deliverable.stubs(:find).with(11).returns @deliverable
    end
    it "should load the deliverable that the reviews belong to" do
      get :index, :project_id => 10, :deliverable_id => 11
      assigns[:deliverable].should == @deliverable
      assigns[:deliverable].latest_version.each {|sub| sub.review.should_not be_nil}
    end
  end

end
