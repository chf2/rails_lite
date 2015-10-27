require_relative 'searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    opts = {class_name: name.to_s.camelcase,
            foreign_key: name.to_s.concat("_id").to_sym,
            primary_key: :id}.merge(options)
    @name = name
    @class_name = opts[:class_name]
    @foreign_key = opts[:foreign_key]
    @primary_key = opts[:primary_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    opts = {class_name: name.to_s.singularize.camelcase,
            foreign_key: self_class_name.downcase.concat("_id").to_sym,
            primary_key: :id}.merge(options)
    @name = name
    @class_name = opts[:class_name]
    @foreign_key = opts[:foreign_key]
    @primary_key = opts[:primary_key]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    define_method(name) do
      foreign_key_val = self.send(options.foreign_key)
      self.class.prefetched_objects.each do |obj|
        if obj.is_a?(options.model_class)
          return obj if obj.id = foreign_key_val
        end
      end
      puts "QUERY FIRED!"
      data = DBConnection.execute(<<-SQL, foreign_key_val)
        SELECT
          *
        FROM
          #{options.table_name}
        WHERE
          #{options.primary_key} = ?
      SQL
      data.empty? ? nil : options.model_class.new(data.first)
    end
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do 
      through_opts = self.class.assoc_options[through_name]
      source_opts = through_opts.model_class.assoc_options[source_name]
      my_fk = self.send(through_opts.foreign_key)
      data = DBConnection.execute(<<-SQL, my_fk)
        SELECT
          #{source_opts.table_name}.*
        FROM
          #{through_opts.table_name}
        INNER JOIN
          #{source_opts.table_name}
        ON #{source_opts.foreign_key} = #{source_opts.table_name}.#{source_opts.primary_key}
        WHERE
          #{through_opts.table_name}.#{through_opts.primary_key} = ?
      SQL
      data.empty? ? nil : source_opts.model_class.new(data.first)
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)
    define_method(name) do 
      data = DBConnection.execute(<<-SQL, id)
        SELECT
          *
        FROM
          #{options.table_name}
        WHERE
          #{options.foreign_key} = ?
      SQL
      options.model_class.parse_all(data)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end
