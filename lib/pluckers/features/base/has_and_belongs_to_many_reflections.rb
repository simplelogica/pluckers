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
      # This module implements plucking has_and_belongs_to_many relationships in a recursive
      # way.
      #
      # The options used in this feature are:
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
      #      other regular option such as attributes, custom ones or even more
      #      reflections. Recursivity FTW!!
      #
      module HasAndBelongsToManyReflections


        ##
        # Here we obtain the has_many reflections to include in the pluck
        # operation and also include the relation foreign key in the attributes to
        # pluck for this model.
        def configure_query
          super

          pluck_reflections = @options[:reflections] || {}

          return if pluck_reflections.blank?

          @has_and_belongs_to_many_reflections = { }

          # We iterate through the class reflections passed as options
          @klass_reflections.slice(*pluck_reflections.keys).
          # And select those that are HasMany
            select{|_, r| active_record_has_and_belongs_to_many_reflection?(r) }.
          # And store them in the has_many_reflection hash that will be used later
            each do |name, reflection|
              name = name.to_sym
              @has_and_belongs_to_many_reflections[name] = pluck_reflections[name]
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

          return if @has_and_belongs_to_many_reflections.blank?

          build_only_ids_has_and_belongs_to_many_reflections
          build_complete_has_and_belongs_to_many_reflections

        end

        ##
        # This method build the reflections completely, creating hashes for each record, etc.
        #
        # It searches reflections that has not the :only_ids option enabled and
        # then creates pluckers for them.
        private def build_complete_has_and_belongs_to_many_reflections

          @has_and_belongs_to_many_reflections.reject {|_, reflection| reflection[:only_ids] }.each do |name, reflection|
            # As an example we will imagine that we are plucking Authors and
            # this relation is the :posts

            # We get the meta information about the reflection
            klass_reflection = @klass_reflections[name]

            # initialize some options such as the plucker or the scope of the pluck
            scope = reflection[:scope] || klass_reflection.klass.send(all_method)
            plucker = reflection[:plucker] || Pluckers::Base

            # We will use the _ids already fetched to check which records we should pluck
            ids_reflection_name = "#{name.to_s.singularize}_ids".to_sym

            ids_to_query = @results.map do |_, result|
              result[ids_reflection_name]
            end

            ids_to_query = ids_to_query.flatten



            # And now we create the plucker. Notice that we add a where to the
            # scope, so we filter the records to pluck as we only get those with
            # an id in the set of the _ids arrays already plucked
            #
            # In our Example we would be doing something like
            # Category.all.where(id: category_ids)
            reflection_plucker = plucker.new scope.where(id: ids_to_query), reflection

            # We initialize so we return an empty array if there are no record
            # related
            @results.each do |_, result|
              result[name] ||= []
            end


            reflection_plucker.pluck.each do |r|
              @results.each do |_,result|
                # For each related result (category) we search those records
                # (BlogPost) that include the category id in its _ids array
                if result[ids_reflection_name].include? r[:id].to_i
                  result[name] << r
                end
              end
            end

            # And now we get rid of duplicates
            @results.each do |_,result|
              result[name].uniq!
            end

          end
        end

        ##
        # This method build the ids for the records instead of creating the hashes.
        #
        # Unlike the has_many relationships, we don't search reflections that
        # has the :only_ids option enabled as we will need these ids also for
        # the other relationships.
        private def build_only_ids_has_and_belongs_to_many_reflections

          @has_and_belongs_to_many_reflections.each do |name, reflection|
            # As an example we will imagine that we are plucking BlogPosts and
            # this relation is the :categories one

            # We get the meta information about the reflection
            klass_reflection = @klass_reflections[name]

            # We get the ids. This query is dependant on the ActiveRecord
            # version, so every feature version has a different implementation
            join_results = has_and_belongs_to_many_ids(klass_reflection)

            ids_reflection_name = "#{name.to_s.singularize}_ids".to_sym

            # Next, we initialize the _ids array for each result
            @results.each do |_, result|
              result[ids_reflection_name] ||= []
            end

            # And now, the foreign_keys.
            # In our example with BlogPost and Category they would be:
            # model_foreign_key = blog_post_id
            # related_model_foreign_key = category_id
            model_foreign_key = klass_reflection.foreign_key
            related_model_foreign_key = klass_reflection.association_foreign_key

            # And for each result we fill the results
            join_results.each do |r|
              @results[r[model_foreign_key].to_i][ids_reflection_name] << r[related_model_foreign_key].to_i
            end

            # And eliminate duplicates
            @results.each do |_,result|
              result[ids_reflection_name].uniq!
            end

          end

        end

      end
    end
  end
end
