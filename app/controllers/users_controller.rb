class UsersController < ApplicationController
  before_filter :find_user
  
  
  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      redirect = session[:redirect_to]
      session[:redirect_to] = nil if redirect
      flash[:notice] = "Your account has been updated"
      redirect_to(redirect || root_path)
    else
      render :action => "edit"
    end
  end


  private
    def find_user
      @user = User.find(params[:id])
    end
end
