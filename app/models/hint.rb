class Hint
  include Mongoid::Document
  field :text, :type => String
  field :node_id, :type => Integer
  
  belongs_to :node
end