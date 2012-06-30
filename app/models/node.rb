class Node
  include Mongoid::Document
  field :hash_str, :type => String # for easy search
  field :count, :type => Integer, :default => 1
  field :assignment_id, :type => Integer
  
  has_many :edges, :foreign_key => :parent_id
  has_many :hints
  belongs_to :assignment
  has_one :proofline
  
  def self.root(assign_id)
    root = Node.where(:hash_str => "root", :assignment_id => assign_id).first
    if root == nil
      root = Node.new({:hash_str => "root", :assignment_id => assign_id})
      root.save!
    end
    root
  end
  
  def valid
    self.proofline.proven rescue false
  end

  def syntax_error
    self.proofline.syntax_error rescue false
  end

  def self.lookup(parent,hash_str)
    @my_child_nodes = []
    parent.edges.each do |x|
      @my_child_nodes << x.child_id
    end
    results = Node.where(hash_str: hash_str).find(@my_child_nodes) rescue nil
    if results
      results.first
    end
    #Node.find(@my_child_nodes).select{|n| n && n.hash_str == hash_str}.first
  end
  
  def self.lookup_hints(hash,assign_id)
    Node.where(:hash_str => hash, :assignment_id => assign_id).map{|n| n.hints}.flatten
  end
  
  def self.check_hash(hash,assign_id)
    Node.where(:hash_str => hash, :assignment_id => assign_id).select{|n| n.proofline.proven}.size > 0
  end
    
  
  def self.register(parent,proofline,status,syntax_error,hash_str)
    # make a new edge
    
    newn = Node.new
    newn.hash_str = hash_str
    newn.assignment_id = parent.assignment_id
    newn.save!
    
    newp = proofline.clone
    newp.proof_id = nil
    newp.node_id = newn.id
    newp.proven = status
    newp.syntax_error = syntax_error
    newp.save!
    newn.proofline = newp
    newn.save!
    
    edge = Edge.new({
      :child_id => newn.id,
      :parent_id => parent.id
    })
    edge.save!

    parent.save!
    newn
  end
  
end


