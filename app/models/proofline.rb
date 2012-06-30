class Proofline
  include Mongoid::Document
  include Mongoid::Timestamps
  cache
  field :conclusion, :type => String
  field :ruleset, :type => String
  field :assumptions, :type => Array
  field :proven, :type => Boolean, :default => false
  field :syntax_error, :type => Boolean, :default => false
  field :node_id, :type => Integer
  
  belongs_to :proof
  belongs_to :node
  
  def hash_str
    self.conclusion + self.ruleset + self.assumptions.join('')  rescue nil
  end
  
  def color
    if self.conclusion == nil
      ""
    elsif self.proven == true
      "green"
    elsif self.syntax_error == true
      "brown"
    else
      "red"
    end
  end
  
  def sanitize_ruleset
    rs = self.ruleset
    if rs == "1fds*kslng8"
      "Free"
    else
      rs
    end
  end
  
end
