class Proof
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  
  field :assignment_id, :type => Integer
  field :user_id, :type => Integer
  field :finished, :type => Boolean, :default => false

  
  accepts_nested_attributes_for :prooflines, :allow_destroy => true, :reject_if => lambda { |a| a[:conclusion].blank? || a[:assumptions].blank? || a[:ruleset].blank? }
  has_many :prooflines, :dependent => :destroy, :autosave => true
  belongs_to :assignment
  belongs_to :user  
end
