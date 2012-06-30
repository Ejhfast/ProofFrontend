class Log
  include Mongoid::Document
  include Mongoid::Timestamps
  field :line, :type => String
end