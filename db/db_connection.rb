require 'pg'

class DBConnection < PG::Connection
  def initialize
    super(
      host: "",
      dbname: "",
      port: "",
      password: "",
      user: "",
    )
  end

  def self.execute(*args)
    self.exec(*args)
  end

  def self.execute_params(*args)
    self.exec_params(*args)
  end
end
