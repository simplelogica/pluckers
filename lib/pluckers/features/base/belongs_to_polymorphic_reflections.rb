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
      # This module implements plucking belongs_to polymorphic relationships in
      # a recursive way.
      #
      # The options used in this feature are:
      #
      #  * reflections: A hash of the reflections we will pluck recursively. The
      #    key of this hash will be the name of the reflection and the value is
      #    another hash of options.
      #
      #    In the case of a polymorphic relationship, this options will be a hash
      #    where you will set the plucking options for each different
      #    available model. Keys of the hash wil be names of the models and
      #    the values will be the regular options for a standard reflection:
      #
      #       - scope: You can limit the scope of the objects plucked. E.g, you
      #         could use Author.active instead of Author.all. Notice that .all is
      #         the default.
      #
      #       - plucker: You can use a custom plucker instead of Pluckers::Base in
      #         case you want any specific logic. Pluckers::Base is the default
      #         one.
      #
      #       - Any other option will be passed to the plucker, so you can send any
      #         other regular option such as attributes, custom ones or even more
      #         reflections. Recursivity FTW!! (even in polymorphic relations)
      #
      module BelongsToPolymorphicReflections


        ##
        # Here we obtain the belongs_to reflections to include in the pluck
        # operation and also include the relation foreign key in the attributes to
        # pluck for this model.
        def configure_query
          super

          pluck_reflections = @options[:reflections] || {}

          return if pluck_reflections.blank?

          @belongs_to_polymorphic_reflections = { }

          # We iterate through the class reflections passed as options
          @klass_reflections.slice(*pluck_reflections.keys).
          # And select those that are BelongsTo
            select{|_, r| active_record_belongs_to_polymorphic_reflection?(r) }.
          # And store them in the belongs_to_reflection hash that will be used later
            each do |name, reflection|
              name = name.to_sym
              @belongs_to_polymorphic_reflections[name] = pluck_reflections[name]
            end

          # First thing we do is to include the foreign key in the attributes to
          # pluck array, so the base plucker plucks them
          @belongs_to_polymorphic_reflections.each do |name, _|

            foreign_key_name = @klass_reflections[name].foreign_key
            @attributes_to_pluck << {
              name: foreign_key_name.to_sym,
              sql: foreign_key_name
            }

            foreign_type = @klass_reflections[name].foreign_type
            @attributes_to_pluck << {
              name: foreign_type.to_sym,
              sql: foreign_type
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

          return if @belongs_to_polymorphic_reflections.blank?
          # For each reflection
          @belongs_to_polymorphic_reflections.each do |name, reflection|
            # As an example we will imagine that we are plucking BlogPosts and
            # this relation is the Subject

            # First, we get the meta information about the reflection
            klass_reflection = @klass_reflections[name]


            reflection_primary_key = klass_reflection.active_record_primary_key.to_sym
            reflection_foreign_key = klass_reflection.foreign_key.to_sym
            reflection_foreign_type = klass_reflection.foreign_type.to_sym

            # Now, we group all the already plucked _type and _id attributes, so
            # we can pluck the polymorphic models
            polymporphic_models = {}

            @results.each do |_, r|
              next if r[reflection_foreign_type].nil? || r[reflection_foreign_key].nil?
              polymporphic_models[r[reflection_foreign_type]] ||= []
              polymporphic_models[r[reflection_foreign_type]] << r[reflection_foreign_key]
            end

            # Now we have a hash like {
            #   "Category" => [1, 2, 3], "Author" => [4, 2, 8]
            # }

            # We initialize so we return a nil if there are no record related
            @results.each do |_,result|
              result[name] = nil
            end

            polymporphic_models.each do |model_name, model_ids|

              model_options = reflection[model_name.to_sym]

              # If there are no options for a model we don't pluck them
              next if model_options.nil?

              # initialize some options such as the plucker or the scope of the pluck
              scope = model_options[:scope] || model_name.constantize.send(all_method)
              plucker = model_options[:plucker] || Pluckers::Base

              # And now we create the plucker. Notice that we add a where to the
              # scope, so we filter the records to pluck as we only get those with
              # an id in the set of the foreign keys of the records already
              # plucked by the base plucker
              #
              # In our Example we would be doing something like
              # Author.all.where(id: author_ids)
              reflection_plucker = plucker.new scope.where(
                  reflection_primary_key => model_ids
                ),
                model_options

              # And now pluck the related class and process the results
              reflection_plucker.pluck.each do |r|
                # For each related result (Author or Category) we search those
                # records (BlogPost) that are related (post.subject_id ==
                # author.id o post.subject_id == category.id) and insert them in
                # the relationship attributes
                @results.each do |_,result|
                  if result[reflection_foreign_key] == r[reflection_primary_key] &&
                      result[reflection_foreign_type] == model_name
                    result[name] = r
                  end
                end
              end
            end
          end
        end

      end
    end
  end
end
