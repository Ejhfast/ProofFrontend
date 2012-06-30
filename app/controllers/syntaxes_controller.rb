class SyntaxesController < ApplicationController
  
  def new
    @assignment = Assignment.find(params[:assignment_id])
    @syntax = Syntax.new
    render :layout => false
  end
  
  def create
    @assignment = Assignment.find(params[:assignment_id])
    @syntax = Syntax.new(params[:syntax])
    @syntax.save!
    redirect_to edit_assignment_path @assignment
  end
  
  def edit
    @assignment = Assignment.find(params[:assignment_id])
    @syntax = Syntax.find(params[:id])
    render :layout => false
  end
  
  def update
    @assignment = Assignment.find(params[:assignment_id])
    @syntax = Syntax.find(params[:id])
    @syntax.update_attributes(params[:syntax])
    @syntax.save!
    redirect_to edit_assignment_path @assignment
  end
  
  def destroy
    @assignment = Assignment.find(params[:assignment_id])
    @syntax = Syntax.find(params[:id])
    @syntax.destroy
    redirect_to edit_assignment_path @assignment
  end
    
end
