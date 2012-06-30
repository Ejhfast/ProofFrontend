require 'patron'
require 'uri'
require 'net/http'

class ProofsController < ApplicationController
  
  before_filter :login
  
  def create
    @assignment = Assignment.find(params[:assignment_id])
    @proof = Proof.new(params[:proof])
    @proof.user_id = current_user.id
    Node.root(@assignment.id) #since we are creating, not updating...
    @proof.save!
    
    verify_proof
    
    respond_to do |format|
      format.html { redirect_to assignment_path @assignment }
      format.js { render 'update.js.erb', :layout => false }
    end
    
  end
  
  def update
    @assignment = Assignment.find(params[:assignment_id])
    @temp_parent = Node.root(@assignment.id)
    @node_id = nil
    @proof = Proof.find(params[:id])
    @proof.update_attributes(params[:proof])
    @proof.finished = false
        
    @log = Log.new(:line => params[:proof].to_s)
    @log.save!
    
    # @old = Proof.find(params[:id])
    #     @old.update_attributes(params[:proof])
    #     @proof = @old.clone #don't save the old one
    #     @proof.user_id = current_user.id
    #     @proof.finished = false # Since we are updating...
    #     @proof.save!
    #         
    #     @oldpl = @old.prooflines.cache
    #         
    #     @oldpl.each do |pl|
    #       newl = pl.clone
    #       newl.proof_id = @proof.id
    #       newl.save!
    #     end
    
    @proof.save!
            
    verify_proof
        
    respond_to do |format|
      format.html {redirect_to assignment_path(@assignment)}
      format.js { render :layout => false }
    end
    
  end
  
  def destroy
    
    #unorthodox delete behavior
    assignment = Assignment.find(params[:assignment_id])
    # proof = Proof.new(:user_id => current_user.id, :assignment_id => assignment.id)
    #     proof.save!
    proof = Proof.find(params[:id])
    proof.prooflines = []
    proof.finished = false
    proof.save!
    redirect_to assignment_path assignment
  end
  
end
