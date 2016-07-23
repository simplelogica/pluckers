module Pluckers

  ##
  # This is the base class for all pluckers.
  #
  # It receives all the configuration in the `initialize` method and performs
  # all the sql queries and hash building inside the `pluck` method.
  class Base

    ##
    # In the initialize method we recive all the options for the plucker.
    #
    # First, we receive an ActiveRecord Relation. It can be any ActiveRecord
    # scope such as `BlogPost.all` or `BlogPost.published`. If we want to
    # pluck a particular object we could pass `BlogPost.where(id: post.id )`
    # so we have an ActiveRecord relation.
    #
    # The options hash allows us to send a lot of configuration:
    #
    #  * attributes: Names of attributes of the objects to be plucked. This
    #    attributes should be the names of the columns in the database.
    #
    # The options hash can be used by subclasses to decorate all this
    # behaviour and send params inside the plucker.
    def initialize records, options = {}
      @records = records
      @options = options
      @options[:attributes] = default_attributes unless @options[:attributes]
      initialize_attributes(@options[:attributes])
    end

    ##
    # This method performs all the sql and hash building according to the
    # received configuration.
    def pluck
      return [] if @records.blank?

      initialize_query

      # First, we check wich attributes we should pluck
      pluck_simple_attributes

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

        # Now we store it in the results array
        @results << attributes_to_return
      end

      # And return the results
      @results
    end

    ##
    # This private method initializes the attributes to be retrieved. Right now it
    # only checks that the requested attributes exists in this model, but in
    # the future could be used for more features, such as translated attributes or
    # alias.
    private def initialize_attributes attributes
      plucker_attributes = attributes.map(&:to_sym)

      klass_attributes = @records.attribute_names.map(&:to_sym)

      # Validate that all attributes exists in the model
      if (missing_attributes = plucker_attributes - klass_attributes).any?
        raise ArgumentError.new("Plucker attributes '#{missing_attributes.to_sentence}', are missing in #{@records.klass}")
      end

      # Split attributes in normal attributes and translated
      @simple_attributes = plucker_attributes & klass_attributes
    end

    ##
    # This private method returns the default attributes that must be retrieved
    private def default_attributes records = @records
      records.attribute_names
    end

    ##
    # We reset all the query information, including the results
    private def initialize_query
      @query_to_pluck = @records
      @attributes_to_pluck = []
      @results = []
    end

    ##
    # In this method we create the array of attributes to pluck
    private def pluck_simple_attributes
      @attributes_to_pluck += @simple_attributes.map {|f| { name: f, sql: f }}
    end

  end
end
