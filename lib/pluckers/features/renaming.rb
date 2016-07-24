module Pluckers
  ##
  # This module groups diferent modules that will configure and build the
  # results for a specific kind of information (attributes, translations,
  # relations...)
  #
  # All this modules will have two methods, one for configuration (e.g, attributes
  # to be included in the real pluck) and one for building the final results
  module Features

    ##
    # This module implements plucking belongs_to relationships in a recursive
    # way.
    #
    # The options used in this feature are:
    #
    #  * renames: A hash of the attributes/reflections/whatever that will be
    #    renamed. The key is the old name and the value is the new name.
    #
    module Renaming


      ##
      # Here we obtain the renames enabled for this plucker
      def configure_query
        super

        @renames = @options.delete(:renames)
        @renames ||= {}
        @renames = @renames.with_indifferent_access

      end

      ##
      # In this method we get the renames and check result by result which
      # ones must be applied
      def build_results
        super

        @renames.each do |old_name, new_name|
          @results.each do |_,result|
            if result.keys.include? old_name.to_sym
              result[new_name.to_sym] = result.delete(old_name.to_sym)
            end
          end
        end

      end

    end
  end
end
