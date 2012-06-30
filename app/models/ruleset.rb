class Ruleset
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  field :name, :type => String
  field :description, :type => String
  field :free, :type => Boolean, :default => false
  field :assignment_id, :type => Integer
  
  belongs_to :assignment
  has_many :rules, :dependent => :destroy, :autosave => true
  has_many :constraints, :dependent => :destroy, :autosave => true
  accepts_nested_attributes_for :rules, :allow_destroy => true, :reject_if => lambda { |a| a[:lhs].blank? || a[:rhs].blank? }
  accepts_nested_attributes_for :constraints, :allow_destroy => true, :reject_if => lambda { |a| a[:var].blank? || a[:cons].blank? }
  
  
  def duplicate(assign)
    rs = self.clone
    rs.assignment_id = assign.id
    self.rules.each do |r|
      nr = r.clone
      nr.ruleset_id = rs.id
      nr.save!
    end
    rs.save!
    rs
  end
  
  def constraints_string
    if self.constraints.size == 0
      ""
    else
      str = "_[";
      s_cons = self.constraints.map do |c|
        c.var.to_s + "::(" + c.cons.to_s + ")"
      end
      str + s_cons.join(",") + "]"
    end
  end
  
end
