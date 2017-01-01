module Pluckers
  ##
  # This module groups diferent modules that will configure and build the
  # results for a specific kind of information (attributes, translations,
  # relations...)
  #
  # All this modules will have two methods, one for configuration (e.g, attributes
  # to be included in the real pluck) and one for building the final results
  module Features

    module Base

      ##
      # This module implements the actual pluck. In ActiveRecord 4 and greater
      # it just uses the standard `pluck' method but in other AR versions it
      # could need some customizations.
      module Pluck

        def pluck_records fields_to_pluck
          @records.pluck(*fields_to_pluck)
        end

        def all_method
          :all
        end

      end
    end
  end
end
