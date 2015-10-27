require 'pg'

class DBConnection < PG::Connection
  def initialize
    super(
      host: ENV["db_host"],
      dbname: ENV["db_dbname"],
      port: ENV["db_port"],
      password: ENV["db_password"],
      user: ENV["db_user"],
    )
  end

  def self.execute(*args)
    self.exec(*args)
  end

  def self.execute_params(*args)
    self.exec_params(*args)
  end
end
