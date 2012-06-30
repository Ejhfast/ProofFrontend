class User
  include Mongoid::Document
  include ActiveModel::SecurePassword
  has_secure_password
  
  field :ext_id, :type => String
  field :email, :type => String
# default value is a hack to make it pass password check for external accounts
  field :password_digest, :type => String, :default => "$2a$10$/0axCfNZN.ij8Xz3VX23Aub/cRdbpZGOyARGvBFPRTAFqv2EJG5di"
  field :name, :type => String
  field :instructor, :type => Boolean, :default => false
  field :external, :type => Boolean, :default => false
  
  validates_presence_of :ext_id, :on => :create, :if => lambda { self.external? }
  validates_presence_of :password, :on => :create, :unless => lambda { self.external? }
  validates_presence_of :email, :unless => lambda { self.external? }
  validates_uniqueness_of :email, :unless => lambda { self.external? }
  validates_presence_of :name
end
