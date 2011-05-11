require 'spec_helper'

describe SessionsController do
  describe "(Functional)" do
    describe "POST to create" do
      describe "when request was" do
        before(:each) do
          @openid = Object.new #don't care which object
          @openid.stubs(:display_identifier).returns "http://someidentifier"
          @hash = {}
          @hash[Rack::OpenID::RESPONSE] = @openid
          @user = User.new()
          @user.stubs(:id).returns(13)
          OpenID::AX::FetchResponse.stubs(:from_success_response)
          request.stubs(:env).returns @hash
        end
      
        describe "failure" do
          it "should render problem template" do
            @openid.expects(:status).returns(:failure)
            post :create
            response.should render_template("sessions/problem") 
          end
        end
      
        describe "successful" do
          before(:each) do
            @openid.expects(:status).returns(:success)
            User.expects(:where).returns([@user])          
          end
          it "should assign session[user.id] if successful" do
            post :create
            session[:user_id].should == 13
          end

          it "should redirect to edit path if user not complete" do
            @user.stubs(:complete?).returns false
            post :create
            response.should redirect_to("/users/13/edit") 
          end

          it "should redirect to root path if user is complete and no redirect is set" do
            @user.stubs(:complete?).returns true
            post :create
            response.should redirect_to("/") 
          end

          it "should redirect to redirect path if user is complete and redirect is set" do
            @user.stubs(:complete?).returns true
            session[:redirect_to] = "/some/redirect"
            post :create
            response.should redirect_to("/some/redirect") 
          end
        end
      end
      
      describe "when request came back inconclusive" do
        it "should redirect back to create a new session" do
          @hash = {}
          @hash[Rack::OpenID::RESPONSE] = nil
          request.stubs(:env).returns @hash
          post :create
          response.should redirect_to("/sessions/new")
        end
      end
    end#POST to create

    describe "DELETE to destroy" do
      it "should clear the user_id from the session variable" do
        session[:user_id] = 99
        delete :destroy
        session[:user_id].should be_nil
      end
      it "should clear the redirect to from the session variable" do
        session[:redirect_to] = "/some/path"
        delete :destroy
        session[:redirect_to].should be_nil
      end
      it "should redirect to the root path" do
        delete :destroy
        response.should redirect_to("/")
      end
    end#DELETE to destroy
    
  end#Functional
end#SessionsController
