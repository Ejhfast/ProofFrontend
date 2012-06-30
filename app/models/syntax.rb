class Syntax
  include Mongoid::Document
  field :name, :type => String
  field :args, :type => Integer
  field :assignment_id, :type => Integer
  
  belongs_to :assignment, :inverse_of => :syntaxes
end
