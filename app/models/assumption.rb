class Assumption
  include Mongoid::Document
  field :name, :type => String
  field :assignment_id, :type => Integer
  
  belongs_to :assignment
  
end
