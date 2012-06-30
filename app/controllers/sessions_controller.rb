class SessionsController < ApplicationController

  def new
    if current_user
      complete_login
    end
  end
  
  def create
    user = User.where(email: params[:email]).first
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:success] = "Logged in!"
      complete_login
    else
      flash[:error] = "Failed to login, try again."
      render :new
    end
  end

  def complete_login
    if session[:return_to]
      @redirect = session[:return_to]
      session.delete :return_to
      redirect_to @redirect
    else
      redirect_to assignments_path
    end
  end
  
  def destroy
    session[:user_id] = nil
    flash[:notice] = "Logged out."
    redirect_to root_path
  end

  def stanford_login
    session[:stanford] = true
    if session[:return_to]
      redirect_to 'http://stanford.coursera.org/compilers/auth/external_redirector?callback=' + session[:return_to]
    elsif current_user
      redirect_to assignments_path
    else
      redirect_to 'http://stanford.coursera.org/compilers/auth/external_redirector?callback=' + request.url
    end
  end

  def public_login
    session[:stanford] = false
    if session[:return_to]
      redirect_to 'http://class.coursera.org/compilers/auth/external_redirector?callback=' + session[:return_to]
    elsif current_user
      redirect_to assignments_path
    else
      redirect_to 'http://class.coursera.org/compilers/auth/external_redirector?callback=' + request.url
    end
  end

end
