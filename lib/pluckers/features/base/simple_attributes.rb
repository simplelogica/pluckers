module Pluckers
  ##
  # This module groups diferent modules that will configure and build the
  # results for a specific kind of information (attributes, translations,
  # relations...)
  #
  # All this modules will have two methods, one for configuration (e.g, fields
  # to be included in the real pluck) and one for building the final results
  module Features

    module Base

      ##
      # This module implements fetching simple attributes (columns) from the
      # database through the AR's pluck method.
      #
      # The options used in this feature are:
      #
      #  * attributes: Names of attributes of the objects to be plucked. This
      #    attributes should be the names of the columns in the database.
      module SimpleAttributes


        ##
        # Here we initialize the simple attributes to be retrieved and checks
        # that those attributes exists in the current scope.
        def configure_query
          super

          attributes = @options[:attributes]
          attributes ||= default_attributes

          plucker_attributes = attributes.map(&:to_sym)

          klass_attributes = @records.attribute_names.map(&:to_sym)

          # Validate that all attributes exists in the model
          if (missing_attributes = plucker_attributes - klass_attributes).any?
            raise ArgumentError.new("Plucker attributes '#{missing_attributes.to_sentence}', are missing in #{@records.klass}")
          end

          simple_attributes = plucker_attributes & klass_attributes

          @attributes_to_pluck += simple_attributes.map {|f| { name: f, sql: "#{@records.klass.connection.quote_table_name @records.table_name}.#{f}" }}

        end

        ##
        # We don't need to perform any extra operation as the pluck is executed
        # in the Pluckers::Base class. We could omit this definition, but leave
        # it for example purposes.
        def build_results
          super
        end

        ##
        # This private method returns the default attributes that must be retrieved
        private def default_attributes records = @records
          records.attribute_names
        end
      end
    end
  end
end
