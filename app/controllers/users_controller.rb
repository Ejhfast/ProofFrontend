class UsersController < ApplicationController
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if(@user.save)
      session[:user_id] = @user.id
      if session[:return_to]
        @redirect = session[:return_to]
        session.delete :return_to
        redirect_to @redirect
      else
        redirect_to root_path
      end
    else
      render :new
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])    
    respond_to do |format|
      if (@user.update_attributes(params[:user]))    
        flash[:notice] = "User updated."
        format.html{ redirect_to edit_user_path(current_user.id) }
        format.js
      else
        format.html { render :action => "edit" }
        format.js
      end
    end
  end
  
end
