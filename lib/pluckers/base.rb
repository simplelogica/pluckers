require_relative 'features/simple_attributes'
require_relative 'features/belongs_to_reflections'
require_relative 'features/has_many_reflections'

module Pluckers

  ##
  # This is the base class for all pluckers.
  #
  # It receives all the configuration in the `initialize` method and performs
  # all the sql queries and hash building inside the `pluck` method.
  class Base

    ##
    # In this attribute we store the ActiveRecord Relation we use to fetch
    # information from the database
    attr_reader :records

    ##
    # In the initialize method we recive all the options for the plucker.
    #
    # First, we receive an ActiveRecord Relation. It can be any ActiveRecord
    # scope such as `BlogPost.all` or `BlogPost.published`. If we want to
    # pluck a particular object we could pass `BlogPost.where(id: post.id )`
    # so we have an ActiveRecord relation.
    #
    # The options hash allows us to send a lot of configuration that will be
    # used by all the features and subclasses to decorate the very basic
    # behaviour.
    #
    # Currently, the options supported by the features included in this base
    # plucker are:
    #
    #  * attributes: Names of attributes of the objects to be plucked. This
    #    attributes should be the names of the columns in the database.
    #
    #  * reflections: A hash of the reflections we will pluck recursively. The
    #    key of this hash will be the name of the reflection and the value is
    #    another hash of options.
    #
    #    - scope: You can limit the scope of the objects plucked. E.g, you
    #      could use Author.active instead of Author.all. Notice that .all is
    #      the default.
    #
    #    - plucker: You can use a custom plucker instead of Pluckers::Base in
    #      case you want any specific logic. Pluckers::Base is the default one.
    #
    #    - Any other option will be passed to the plucker, so you can send any
    #      other regular option such as fields, custom ones or even more
    #      reflections. Recursivity FTW!!
    #
    # The options hash can be used by subclasses to decorate all this
    # behaviour and send params inside the plucker.
    def initialize records, options = {}
      @records = records
      @options = options
      @features = @options.delete(:features)
    end

    ##
    # This method performs all the sql and hash building according to the
    # received configuration.
    def pluck
      return [] if @records.blank?

      configure_query

      build_results

      # And return the results
      @results.values
    end

    ##
    # In this base implementation we just reset all the query information.
    # Features and subclasses must redefine this method if they are interested
    # in adding some behaviour.
    def configure_query
      @query_to_pluck = @records
      @attributes_to_pluck = [{ name: @query_to_pluck.primary_key.to_sym, sql: @query_to_pluck.primary_key }]
      @results = {}
      @klass_reflections = @query_to_pluck.reflections.with_indifferent_access

      pluck_reflections = @options[:reflections] || {}

      # Validate that all relations exists in the model
      if (missing_reflections = pluck_reflections.symbolize_keys.keys - @klass_reflections.symbolize_keys.keys).any?
        raise ArgumentError.new("Plucker reflections '#{missing_reflections.to_sentence}', are missing in #{@records.klass}")
      end
    end

    ##
    # In this base implementation we perform the real pluck execution.
    #
    # The method collects all the attributes and columns to pluck and add it
    # to the results array.
    def build_results

      # Now we uinq the attributes
      @attributes_to_pluck.uniq!{|f| f[:name] }

      # Obtain both the names and SQL columns
      names_to_pluck = @attributes_to_pluck.map{|f| f[:name] }
      sql_to_pluck = @attributes_to_pluck.map{|f| f[:sql] }


      # And perform the real ActiveRecord pluck.
      @records.pluck(*sql_to_pluck).each_with_index do |record, index|
        # After the pluck we have to create the hash for each record.

        # If there's only a field we will not receive an array. But we need it
        # so we built it.
        record = [record] unless record.is_a? Array
        # Now we zip it with the attribute names and create a hash. If we have
        # have a record: [1, "Test title 1", "Test text 1"] and the
        # names_to_pluck are [:id, :title, :text] we will end with {:id=>1,
        # :title=>"Test title 1", :text=>"Test text 1"}
        attributes_to_return = Hash[names_to_pluck.zip(record)]

        # Now we store it in the results hash
        @results[attributes_to_return[:id]] = attributes_to_return
      end
    end

    # Now we add all the base features
    prepend Features::SimpleAttributes
    prepend Features::BelongsToReflections
    prepend Features::HasManyReflections

  end
end
