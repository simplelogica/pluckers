module Pluckers
  module Features
    module Pluck

      ##
      # In ActiveRecord 3.2 pluck only accepts one column. We have to go
      # around it and not actually use the pluck method.
      #
      # Idea based on http://meltingice.net/2013/06/11/pluck-multiple-columns-rails/
      def pluck_records(*fields_to_pluck)
        records_clone = @records.clone
        records_clone.select_values = fields_to_pluck
        @records.connection.select_all(records_clone.arel).map do |attributes|
          initialized_attributes = @records.klass.initialize_attributes(attributes)
          attributes.each do |key, attribute|
            attributes[key] = @records.klass.type_cast_attribute(key, initialized_attributes)
          end
        end
      end

      def all_method
        :scoped
      end
    end
  end
end
