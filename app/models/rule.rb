class Rule
  include Mongoid::Document
  field :lhs, :type => String
  field :rhs, :type => String
  field :type, :type => String
  field :ruleset_id, :type => Integer
  
  belongs_to :ruleset
  
  def gen_type
    if self.type == "="
      "~>"
    else
      ":="
    end
  end
  
end
