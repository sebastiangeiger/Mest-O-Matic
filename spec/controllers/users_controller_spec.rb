require 'spec_helper'

describe UsersController do
  render_views
  
  before(:each) do
    @user = User.new
    @user.stubs(:email).returns("some.one@meltwater.org")
    @staff = Staff.new
  end
  
  describe "(Authorization)" do
    before(:each) do
      @user.stubs(:id).returns(12)
      User.stubs(:find).with(12).returns(@user)
      @userB = User.new
      @userB.stubs(:email).returns("somebody.else@meltwater.org")
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
      it "should not grant access to a not logged in user" do
        controller.expects(:signed_in?).returns false
        get :unassigned_roles
        response.should redirect_to(new_sessions_path)
      end

      it "should grant access to a staff member" do
        controller.expects(:signed_in?).returns true
        controller.expects(:current_user).returns @staff
        get :unassigned_roles
        response.should be_success
      end

      it "should not grant access to an eit but redirect him to the root" do
        @eit = Eit.new
        controller.expects(:signed_in?).returns true
        controller.expects(:current_user).returns @eit
        get :unassigned_roles
        response.should redirect_to("/")
      end
    end

    describe "PUT 'assign_roles'" do
      it "should not grant access to a not logged in user" do
        controller.expects(:signed_in?).returns false
        put :assign_roles
        response.should redirect_to(new_sessions_path)
      end

      it "should grant access to a staff member" do
        User.stubs(:update) #don't do the update
        controller.expects(:signed_in?).returns true
        controller.expects(:current_user).returns @staff
        put :assign_roles, :users => {"99" => {:type => "Eit"}}
        response.should redirect_to("/users/unassigned_roles")
      end

      it "should not grant access to an eit but redirect him to the root" do
        @eit = Eit.new
        controller.expects(:signed_in?).returns true
        controller.expects(:current_user).returns @eit
        put :assign_roles
        response.should redirect_to("/")
      end
    end
  end
  
  describe "(Functional)" do
    before(:each) do
      controller.stubs(:signed_in?).returns true
      @user.stubs(:id).returns 12
    end
    
    describe "GET 'edit'" do
      it "should load the current user, assign it and render the edit template" do
        controller.stubs(:current_user).returns @user
        User.expects(:find).with(12).returns @user
        get :edit, :id => 12
        assigns[:user].should == @user
        response.should render_template("users/edit")
      end
    end

    describe "PUT 'update'" do
      it "should load the current user" do
        controller.stubs(:current_user).returns @user
        User.expects(:find).with(12).returns @user 
        put 'update', :id => 12
        assigns[:user].should == @user
      end

      describe "valid parameters" do
        it "should show a flash message" do
          controller.stubs(:current_user).returns @user
          User.any_instance.stubs(:valid?).returns true
          User.expects(:find).with(12).returns @user
          put 'update', :id => 12
          flash[:notice].should_not be_nil
        end


        it "should redirect to root if no session[:redirect_to] is set" do
          controller.stubs(:current_user).returns @user
          User.any_instance.stubs(:valid?).returns true
          User.expects(:find).with(12).returns @user
          put 'update', :id => 12
          response.should redirect_to(root_path)
        end
        
        it "should redirect to the previously requested site if a session[:redirect_to] is set and then unset it" do
          controller.stubs(:current_user).returns @user
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
          controller.stubs(:current_user).returns @user
          User.any_instance.stubs(:valid?).returns false
          User.expects(:find).with(12).returns @user
          put 'update', :id => 12
          response.should render_template("users/edit")
        end
      end
    end
    
    describe "GET 'unassigned_roles'" do
      it "should load all users that have an unassigned role" do
        controller.stubs(:current_user).returns @staff
        @users = [User.new, User.new]
        User.expects(:all_unassigned).returns @users
        get :unassigned_roles
        assigns[:users].should == @users
        response.should render_template("users/unassigned_roles")
      end
    end

    describe "PUT 'assign_roles'" do
      it "should call update on users with the parameters provided and go to the unassigned_roles page if all users are valid" do
        User.any_instance.stubs(:errors).returns []
        controller.stubs(:current_user).returns @staff
        User.expects(:update).with(["3","4"], [{"role" => "Staff"}, {"role" => "Eit (Class of 2012)"}])
        put :assign_roles, :users => {"3" => {:role => "Staff"}, "4" => {:role => "Eit (Class of 2012)"}}
        response.should redirect_to("/users/unassigned_roles")
      end

      it "should call update on users with the parameters provided and render the unassigned_roles page if one of the users is not valid" do
        fail_user = User.new
        fail_user.stubs(:errors).returns ["some error"]
        controller.stubs(:current_user).returns @staff
        User.expects(:update).with(["3"], [{"role" => "Staff"}]).returns [fail_user]
        put :assign_roles, :users => {"3" => {:role => "Staff"}}
        response.should render_template("users/unassigned_roles")
      end

      it "should call update on users and retry for users that could not be saved" do
        success_user = User.new
        success_user.stubs(:errors).returns []
        fail_user = User.new
        fail_user.stubs(:errors).returns ["Fail"]
        controller.stubs(:current_user).returns @staff
        User.expects(:update).with(["3", "4"], [{"role" => "Staff"}, {"role" => "Nonsense"}]).returns [success_user, fail_user]
        put :assign_roles, :users => {"3" => {:role => "Staff"}, "4" => {:role => "Nonsense"}}
        assigns[:users].should == [fail_user]
        response.should render_template("users/unassigned_roles")
      end
    end

    
  end
end
