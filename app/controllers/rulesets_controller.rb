class RulesetsController < ApplicationController
  def new
    @ruleset = Ruleset.new
    @assignment = Assignment.find(params[:assignment_id])
    1.times { @ruleset.rules.build }
    1.times { @ruleset.constraints.build }
    render :layout => false
  end
  
  def create
    assignment = Assignment.find(params[:assignment_id])
    ruleset = Ruleset.new(params[:ruleset])
    ruleset.save!
    redirect_to edit_assignment_path assignment
  end
  
  def edit
    @assignment = Assignment.find(params[:assignment_id])
    @ruleset = Ruleset.find(params[:id])
    1.times { @ruleset.constraints.build }
    render :layout => false
  end
  
  def update
    assignment = Assignment.find(params[:assignment_id])
    ruleset = Ruleset.find(params[:id])
    ruleset.update_attributes(params[:ruleset])
    ruleset.save!
    redirect_to edit_assignment_path assignment
  end
  
  def destroy
    assignment = Assignment.find(params[:assignment_id])
    ruleset = Ruleset.find(params[:id])
    ruleset.destroy
    redirect_to edit_assignment_path assignment
  end
  
end
