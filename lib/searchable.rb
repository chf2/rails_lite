require_relative 'db_connection'
require_relative 'sql_object'
require 'active_support/inflector'

module Searchable
  def where(params)
    if self.class == Relation
      Relation.new(@klass, table_name, @params.merge(params))
    else
      Relation.new(self, table_name, params)
    end
  end

  def includes(included_table_name)
    if self.class == Relation
      included_tables << table_name
    else
      Relation.new(self, table_name, {}, included_table_name)
    end
  end
end

class Relation
  include Searchable
  
  attr_reader :klass, :table_name, :params
  def initialize(klass, table_name, params = {}, included_table = nil)
    @klass, @table_name = klass, table_name
    @params, @included_tables = params, [included_table]
  end

  def method_missing(name, *args)
    if Array.method_defined?(name)
      collection.concat(get_search_results) if @collection.nil?
      collection.concat(included_collection)
      collection.send("#{name}", *args)
    else
      raise NoNameError "Method not found!"
    end
  end

  def ==(other)
    if other.is_a? Array
      @collection == other
    end
  end

  def collection
    @collection ||= []
  end

  def fire
    collection = get_search_results
    collection.concat(included_collection)
    self
  end

  def included_tables
    @included_tables ||= []
  end

  def included_collection
    @included_collection ||= []
    if @included_collection.empty? && !included_tables.empty?
      included_tables.each do |table|
        results = DBConnection.execute(<<-SQL, *params.values)
          SELECT
            *
          FROM
            #{table}
        SQL
        included_class = table.to_s.singularize.capitalize.constantize
        objects = included_class.parse_all(results)
        klass.prefetched_objects.concat(objects)
        @included_collection.concat(objects)
      end
    end
    @included_collection
  end

  def get_search_results
    where_str = params.keys.map(&:to_s).join(" = ? AND ") + " = ?"
    where_str = "1 = 1" if params.empty?
    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_str}
    SQL
    klass.parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
