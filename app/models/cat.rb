require_relative '../../lib/sql_object.rb'

class Cat < SQLObject
  self.finalize!
end