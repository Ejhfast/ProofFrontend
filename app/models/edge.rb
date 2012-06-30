class Edge
  include Mongoid::Document
  field :child_id, :type => Integer
  
  def get_node
    Node.find(self.child_id)
  end
end