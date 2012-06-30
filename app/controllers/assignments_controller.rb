require 'patron'
require 'uri'
require 'net/http'

class AssignmentsController < ApplicationController
  before_filter :login
  before_filter :instructor?, :only => [:update, :create, :manage, :edit]
  
  def index
    @assignments = Assignment.all
  end
  
  def destroy
    @assignment = Assignment.find(params[:id])
    @assignment.destroy
    redirect_to assignments_path
  end

  def new
    @assignment = Assignment.new
    render :layout => false
  end
  
  def create
    @assignment = Assignment.new(params[:assignment])
    @assignment.save!
    redirect_to assignments_path
  end
  
  def update
    @assignment = Assignment.find(params[:id])
    @assignment.update_attributes(params[:assignment])
    @assignment.save!
    redirect_to edit_assignment_path @assignment
  end
  
  def verify
    @assignment = Assignment.find(params[:id])
    @temp_parent = Node.root(@assignment.id)    
    rulesets = compose_rulesets(@assignment.rulesets)
    assumptions = compose_assumptions(@assignment.assumptions.map{|a| a.name})
    syntax = compose_syntax(@assignment)
    params = {"rulesets" => rulesets, "assumptions" => assumptions, "syntax" => syntax, "goal" => @assignment.goal}
    x = Net::HTTP.post_form(URI.parse('http://test-proof-backend.herokuapp.com/check_assignment'), params)
    render :text => x.body
  end
    

  def show
    @assignment = Assignment.find(params[:id])
    @temp_parent = Node.root(@assignment.id)
    @node_id = nil
    if !@assignment || (!current_user.instructor && !@assignment.visible)
      redirect_to assignments_path
    else
      @proof = Proof.where(:assignment_id => @assignment.id, :user_id => current_user.id).desc(:updated_at).first
      if not @proof
        @proof = Proof.new
      end

      #verify_proof
      @previous_lines = []
      @proof.prooflines.each do |p|
        @previous_lines += [p.conclusion]
      end
      generate_selections
      @proof.prooflines.build
    end
  end
  
  def lookup_children
    @assignment = Assignment.find(params[:id])
    @node = Node.find(params[:node_id])
    render :json => @node.nodes.to_json
  end
  
  def edit
    @assignment = Assignment.find(params[:id])
  end
  
  def manage
    @node = Node.find(params[:node])    
    @assignment = @node.assignment
    @parent = Node.find(params[:parent]) rescue Node.root(@assignment.id)
    @students = Proof.where(:assignment_id => @assignment.id, :finished => true).map{|x| [x.user.name, x.user.email, x.user.instructor]}.uniq
    get_session_state(@node.id, @parent.id)
  end
  
  def toggle
    @node = Node.find(params[:node])    
    @assignment = @node.assignment
    @parent = Node.find(params[:parent]) rescue Node.root(@assignment.id)
    @node.proofline.proven = ! @node.proofline.proven
    @node.proofline.save!
    redirect_to "/manage/#{@node.id}?parent=#{@parent.id}"
  end
  
  def copy
    @assignment = Assignment.find(params[:id])
    @new_assign = Assignment.new
    @new_assign.name = "Copy of " + @assignment.name
    @assignment.rulesets.each do |r|
      @new_assign.rulesets.push(r.duplicate(@new_assign))
    end
    @assignment.syntaxes.each do |s|
      ns = Syntax.new
      ns.name = s.name
      ns.args = s.args
      ns.assignment_id = @new_assign.id
      ns.save
    end
    @new_assign.save!
    redirect_to assignment_path(@new_assign)
  end
  
  def clear_proofs
    @assignment = Assignment.find(params[:id])
    @assignment.proofs = nil
    @assignment.nodes = nil
    @assignment.save!
    redirect_to edit_assignment_path(@assignment)
  end
  
  def instructor?
    if current_user && (not current_user.instructor)
      redirect_to assignments_path
    end
  end

end
