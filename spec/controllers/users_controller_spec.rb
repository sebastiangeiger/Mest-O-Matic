require 'spec_helper'

describe UsersController do
  render_views
  
  before(:each) do
    @user = User.new
    @user.stubs(:email).returns("some.one@meltwater.org")
  end
  
  describe "(Authorization)" do
    before(:each) do
      @user.stubs(:id).returns(12)
      User.stubs(:find).with(12).returns(@user)
      @userB = User.new
      @userB.stubs(:email).returns("some.one@meltwater.org")
      @userB.stubs(:id).returns(99)
      User.stubs(:find).with(99).returns @userB
    end
    describe "GET 'edit'" do
      it "should not grant access to a not logged in user" do
        controller.expects(:signed_in?).returns false
        get :edit, :id => 12
        response.should redirect_to(new_sessions_path)
      end
      it "should turn down a user that wants to edit another user" do
        controller.expects(:signed_in?).returns true
        controller.expects(:current_user).at_least_once.returns @user
        get :edit, :id => 99
        response.should redirect_to("/users/12/edit")
        flash[:error].should_not be_nil
      end
      it "should allow a user that wants to edit himself" do
        controller.expects(:signed_in?).returns true
        controller.expects(:current_user).at_least_once.returns @user
        get :edit, :id => 12
        response.should render_template("users/edit")
      end
    end

    describe "PUT 'update'" do
      it "should not grant access to a not logged in user" do
        controller.expects(:signed_in?).returns false
        put :update, :id => 12
        response.should redirect_to(new_sessions_path)
      end
      it "should turn down a user that wants to update another user" do
        controller.expects(:signed_in?).returns true
        controller.expects(:current_user).at_least_once.returns @user
        put :update, :id => 99
        response.should redirect_to("/users/12/edit")
        flash[:error].should_not be_nil
      end
      it "should allow a user that wants to update himself" do
        controller.expects(:signed_in?).returns true
        controller.expects(:current_user).at_least_once.returns @user
        put :update, :id => 12
        response.should render_template("users/edit")
      end
    end
    
    describe "GET 'unassigned_roles'" do
      it "should grant access to a staff member" do
        @staff = Staff.new
        controller.expects(:current_user).returns @staff
        get :unassigned_roles
        response.should be_success
      end
    end
  end
  
  describe "(Functional)" do
    before(:each) do
      controller.stubs(:signed_in?).returns true
      controller.stubs(:current_user).returns @user
    end
    
    describe "GET 'edit'" do
      it "should load the current user, assign it and render the edit template" do
        User.expects(:find).with(12).returns @user
        get :edit, :id => 12
        assigns[:user].should == @user
        response.should render_template("users/edit")
      end
    end

    describe "PUT 'update'" do
      it "should load the current user" do
        User.expects(:find).with(12).returns @user 
        put 'update', :id => 12
        assigns[:user].should == @user
      end

      describe "valid parameters" do
        it "should show a flash message" do
          User.any_instance.stubs(:valid?).returns true
          User.expects(:find).with(12).returns @user
          put 'update', :id => 12
          flash[:notice].should_not be_nil
        end


        it "should redirect to root if no session[:redirect_to] is set" do
          User.any_instance.stubs(:valid?).returns true
          User.expects(:find).with(12).returns @user
          put 'update', :id => 12
          response.should redirect_to(root_path)
        end
        
        it "should redirect to the previously requested site if a session[:redirect_to] is set and then unset it" do
          User.any_instance.stubs(:valid?).returns true
          User.expects(:find).with(12).returns @user
          session[:redirect_to] = "/projects/new"
          put 'update', :id => 12
          session[:redirect_to].should be_nil
          response.should redirect_to("/projects/new")
        end
      end
      
      describe "invalid parameters" do
        it "should render the edit template" do
          User.any_instance.stubs(:valid?).returns false
          User.expects(:find).with(12).returns @user
          put 'update', :id => 12
          response.should render_template("users/edit")
        end
      end
    end
  end
end
