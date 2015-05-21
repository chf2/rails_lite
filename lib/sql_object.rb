require_relative '../db/db_connection'
require 'active_support/inflector'

# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
    data = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    @columns = data[0].map(&:to_sym) #store an instance varialbe! Caching
  end

  def self.prefetched_objects
    @prefetched_objects ||= []
  end

  def self.finalize!
    columns.each do |column|
      define_method(column) do
        attributes[column]
      end

      define_method("#{column}=") do |val|
        attributes[column] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT 
        *
      FROM
        #{table_name}
    SQL
    parse_all(results)
  end

  def self.parse_all(results)
    instances = []
    results.each do |params|
      instances << self.new(params)
    end

    instances
  end

  # MUCH BETTER THAN CREATE COLLECTION, SHOVEL ELEMENTS
  # def sef.parse_all(results)
  #   results.map { |result| self.new(result) }
  # end

  def self.find(id)
    data = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = :id
      LIMIT 1
    SQL

    data.empty? ? nil : self.new(data[0])
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      unless self.class.columns.include?(attr_name.to_sym)
        raise ArgumentError.new "unknown attribute '#{attr_name}'"
      end
      self.send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  def insert
    cols = self.class.columns
    raise "No columns to insert into" if cols.length < 2
    col_names = "(" + cols[1..-1].join(', ') + ")"
    question_marks = "(" + "?, " * (cols.length - 2) + "?)"
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} #{col_names}
      VALUES
        #{question_marks}
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_str = self.class.columns.drop(1).map do |col|
      "#{col}"
    end.join(" = ?, ") + " = ?"
    p set_str
    DBConnection.execute(<<-SQL, *attribute_values.drop(1), id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_str}
      WHERE
        id = :id 
    SQL
  end

  def save
    id.nil? ? insert : update
  end
end
