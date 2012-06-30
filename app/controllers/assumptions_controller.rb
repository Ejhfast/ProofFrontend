class AssumptionsController < ApplicationController
  def new
    @assignment = Assignment.find(params[:assignment_id])
    @assumption = Assumption.new
    render :layout => false
  end

  def edit
    @assignment = Assignment.find(params[:assignment_id])
    @assumption = Assumption.find(params[:id])
    render :layout => false
  end
  
  def create
    assignment = Assignment.find(params[:assignment_id])
    assumption = Assumption.new(params[:assumption])
    assumption.save!
    redirect_to edit_assignment_path assignment
  end
  
  def update
    assignment = Assignment.find(params[:assignment_id])
    assumption = Assumption.find(params[:id])
    assumption.update_attributes(params[:assumption])
    assumption.save!
    redirect_to edit_assignment_path assignment
  end
  
  def destroy
    assignment = Assignment.find(params[:assignment_id])
    assumption = Assumption.find(params[:id])
    assumption.destroy
    redirect_to edit_assignment_path assignment
  end

end
