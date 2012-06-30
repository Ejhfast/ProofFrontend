class Assignment
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, :type => String
  field :goal, :type => String
  field :hide_goal, :type => Boolean, :default => false
  field :description, :type => String
  field :posted, :type => Date, :default => Time.now
  field :visible, :type => Boolean, :default => false
  
  has_many :rulesets, :dependent => :destroy
  has_many :assumptions, :dependent => :destroy
  has_many :syntaxes, :dependent => :destroy
  has_many :proofs, :dependent => :destroy
  has_many :nodes
  
end
