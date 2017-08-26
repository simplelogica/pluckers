active_record_version = ActiveRecord.respond_to?(:version) ? ActiveRecord.version : Gem::Version.new(ActiveRecord::VERSION::STRING)

if active_record_version > Gem::Version.new("4.2") && active_record_version < Gem::Version.new("5.0")
  require_relative 'features/active_record_4_2'
elsif active_record_version > Gem::Version.new("4.1") && active_record_version < Gem::Version.new("4.2")
  require_relative 'features/active_record_4_1'
elsif active_record_version > Gem::Version.new("4.0") && active_record_version < Gem::Version.new("4.1")
  require_relative 'features/active_record_4_0'
elsif active_record_version > Gem::Version.new("5.0") && active_record_version < Gem::Version.new("5.1")
  require_relative 'features/active_record_5_0'
elsif active_record_version > Gem::Version.new("5.1") && active_record_version < Gem::Version.new("5.2")
  require_relative 'features/active_record_5_1'
elsif active_record_version > Gem::Version.new("3.2") && active_record_version < Gem::Version.new("4.0")
  require_relative 'features/active_record_3_2'
else
  require_relative 'features/active_record_4_2'
end

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
    #    attributes should be the names of the columns in the database. If we are
    #    using Globalize these attributes can also be  the names of the translated
    #    attributes by Globalize.
    #
    #  * attributes_with_locale: A hash when the key is a locale and the value
    #    is an array of attributes to pluck. As a result we will have a series of
    #    attributes with the name following the syntax attreibute_locale. E.g: The
    #    option could be { es: [:name], en: [:name, :location]} and we would obtain
    #    :name_es, :name_en and :location_en keys in the hash result
    #
    #  * renames: A hash of the attributes/reflections/whatever that will be
    #    renamed. The key is the old name and the value is the new name.
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
    #    - only_ids: In has_many reflections we can get the _ids array instead
    #      of an array with hashes if we pass this option as true. If we do any
    #      fields or plucker option will be ignored.
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
      @attributes_to_pluck = [{ name: @query_to_pluck.primary_key.to_sym, sql: "\"#{@query_to_pluck.table_name}\".#{@query_to_pluck.primary_key}" }]
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
      pluck_records(sql_to_pluck).each do |record|
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
        @results[attributes_to_return[ @query_to_pluck.primary_key.to_sym]] = attributes_to_return
      end
    end

    include Features::Pluck

    # Now we add all the base features
    prepend Features::Globalize
    prepend Features::SimpleAttributes
    prepend Features::BelongsToReflections
    prepend Features::BelongsToPolymorphicReflections
    prepend Features::HasManyReflections
    prepend Features::HasManyThroughReflections
    prepend Features::HasAndBelongsToManyReflections
    prepend Features::HasOneReflections
    prepend Features::HasOneThroughReflections
    prepend Features::Renaming

  end
end
