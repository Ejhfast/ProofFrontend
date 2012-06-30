class HintsController < ApplicationController
  def new
    @hint = Hint.new
    @assignment = Assignment.find(params[:assignment_id])
    get_session_state
    render :layout => false
  end
  
  def create
    @hint = Hint.new(params[:hint])
    @hint.node_id = session[:node_id]
    @hint.save!
    redirect_to "/manage/#{session[:node_id]}?parent=#{session[:parent_id]}"
  end
  
  def destroy
    @hint = Hint.find(params[:id])
    @hint.destroy
    redirect_to "/manage/#{session[:node_id]}?parent=#{session[:parent_id]}"
  end
  
end
