class Constraint
  include Mongoid::Document
  field :var, :type => String
  field :cons, :type => String
  field :ruleset_id, :type => Integer
  
  belongs_to :ruleset
  
end