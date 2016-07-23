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
    # This module implements fetching simple attributes (columns) from the
    # database through the AR's pluck method.
    #
    # The options used in this feature are:
    #
    #  * attributes: Names of attributes of the objects to be plucked. This
    #    attributes should be the names of the columns in the database.
    module BelongsToReflections


      ##
      # Here we obtain the belongs_to reflections to include in the pluck
      # operation and also include the relation foreign key in the attributes to
      # pluck for this model.
      def configure_query
        super

        pluck_reflections = @options[:reflections] || {}


        return if pluck_reflections.blank?

        # Validate that all relations exists in the model
        if (missing_reflections = pluck_reflections.symbolize_keys.keys - @klass_reflections.symbolize_keys.keys).any?
          raise ArgumentError.new("Plucker reflections '#{missing_reflections.to_sentence}', are missing in #{@records.klass}")
        end


        @belongs_to_reflections = { }

        # We iterate through the class reflections passed as options
        @klass_reflections.slice(*pluck_reflections.keys).
        # And select those that are BelongsTo
          select{|_, r| r.is_a?(ActiveRecord::Reflection::BelongsToReflection)}.
        # And store them in the belongs_to_reflection hash that will be used later
          each do |name, reflection|
            name = name.to_sym
            @belongs_to_reflections[name] = pluck_reflections[name]
          end

        # First thing we do is to include the foreign key in the fields to
        # pluck array, so the base plucker plucks them
        @belongs_to_reflections.each do |name, _|
          foreign_key_name = @klass_reflections[name].foreign_key
          @attributes_to_pluck << {
            name: foreign_key_name.to_sym,
            sql: foreign_key_name
          }
        end

      end

      ##
      # In this method we get the reflections and for each one creates and
      # executes a new plucker.
      #
      # This pluck gives the whole process a recursive character and options
      # for that plucker may be passed in the options hash.
      def build_results
        super

        return if @belongs_to_reflections.blank?
        # For each reflection
        @belongs_to_reflections.each do |name, reflection|
          # As an example we will imagine that we are plucking BlogPosts and
          # this relation is the Author

          # We get the meta information about the reflection
          klass_reflection = @klass_reflections[name]

          # initialize some options such as the plucker or the scope of the pluck
          scope = reflection[:scope] || klass_reflection.klass.all
          plucker = reflection[:plucker] || Pluckers::Base

          # And now we create the plucker. Notice that we add a where to the
          # scope, so we filter the records to pluck as we only get those with
          # an id in the set of the foreign keys of the records already
          # plucked by the base plucker
          #
          # In our Example we sould be doing something like Author.all.where(id: author_ids)
          reflection_plucker = plucker.new scope.where(
              id: @results.map{|_, r| r[klass_reflection.foreign_key.to_sym] }.compact
            ),
            reflection

          # We initialize so we return a nil if there are no record related
          @results.each do |_,result|
            result[name] = nil
          end

          # And now pluck the related class and process the results
          reflection_plucker.pluck.each do |r|
            # For each related result (Author) we search those records
            # (BlogPost) that are related (post.author_id == author.id) and
            # insert them in the relationship attributes
            @results.each do |_,result|
              if result[klass_reflection.foreign_key.to_sym] == r[:id]
                result[name] = r
              end
            end
          end
        end
      end

    end
  end
end
