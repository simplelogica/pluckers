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
      # This module implements plucking has_many relationships in a recursive
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
      #    - only_ids: We can get the _ids array instead of an array with hashes
      #      if we pass this option as true. If we do any fields or plucker
      #      option will be ignored.
      #
      #    - Any other option will be passed to the plucker, so you can send any
      #      other regular option such as attributes, custom ones or even more
      #      reflections. Recursivity FTW!!
      #
      module HasManyReflections


        ##
        # Here we obtain the has_many reflections to include in the pluck
        # operation and also include the relation foreign key in the attributes to
        # pluck for this model.
        def configure_query
          super

          pluck_reflections = @options[:reflections] || {}

          return if pluck_reflections.blank?

          @has_many_reflections = { }

          # We iterate through the class reflections passed as options
          @klass_reflections.slice(*pluck_reflections.keys).
          # And select those that are HasMany
            select{|_, r| active_record_has_many_reflection?(r)}.
          # And store them in the has_many_reflection hash that will be used later
            each do |name, reflection|
              name = name.to_sym
              @has_many_reflections[name] = pluck_reflections[name]
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

          return if @has_many_reflections.blank?

          build_complete_reflections
          build_only_ids_reflections

        end

        ##
        # This method build the reflections completely, creating hashes for each record, etc.
        #
        # It searches reflections that has not the :only_ids option enabled and
        # then creates pluckers for them.
        private def build_complete_reflections

          @has_many_reflections.reject {|_, reflection| reflection[:only_ids] }.each do |name, reflection|
            # As an example we will imagine that we are plucking Authors and
            # this relation is the :posts

            # We get the meta information about the reflection
            klass_reflection = @klass_reflections[name]


            # initialize some options such as the plucker or the scope of the pluck
            scope = reflection[:scope] || klass_reflection.klass.send(all_method)
            plucker = reflection[:plucker] || Pluckers::Base

            # If there are attributes configured to be plucked we add the foreign
            # key as we will need it to relate the records
            reflection[:attributes] |= [klass_reflection.foreign_key.to_sym] if reflection[:attributes]

            # If the has_many is an :as relationship (inverse of a polymorphic
            # one) we should filter the ones with the right class
            if klass_reflection.options[:as]
              scope = scope.where(klass_reflection.type => klass_reflection.active_record.class_name)
            end

            # And now we create the plucker. Notice that we add a where to the
            # scope, so we filter the records to pluck as we only get those with
            # an id in the set of the foreign keys of the records already
            # plucked by the base plucker
            #
            # In our Example we would be doing something like
            # BlogPost.all.where(author_id: author_ids)
            reflection_plucker = plucker.new scope.where(
                klass_reflection.foreign_key => @results.map{|_, r| r[klass_reflection.active_record_primary_key.to_sym] }
              ),
              reflection

            # We initialize so we return an empty array if there are no record
            # related
            @results.each do |_, result|
              result[name] ||= []
            end

            reflection_plucker.pluck.each do |r|
              @results.each do |_,result|
                # For each related result (Author) we search those records
                # (BlogPost) that are related (author.id == post.author_id) and
                # insert them in the relationship attributes
                if result[klass_reflection.active_record_primary_key.to_sym] == r[klass_reflection.foreign_key.to_sym]
                  result[name] << r
                end
              end
            end

          end
        end

        ##
        # This method build the ids for the records instead of creating the hashes.
        #
        # It searches reflections that has the :only_ids option enabled and then
        # creates pluckers for them.
        private def build_only_ids_reflections

          @has_many_reflections.select {|_, reflection| reflection[:only_ids] }.each do |name, reflection|
            # As an example we will imagine that we are plucking Authors and
            # this relation is the :posts

            # We get the meta information about the reflection
            klass_reflection = @klass_reflections[name]

            # We can send an scope option for filtering the related records
            scope = reflection[:scope] || klass_reflection.klass.send(all_method)

            # We override the attributes as we only get the required ones for
            # relating the records
            reflection[:attributes] = [klass_reflection.foreign_key.to_sym, klass_reflection.active_record_primary_key.to_sym]

            # And now, create the plucker, filtering the records so we only get
            # the related ones
            reflection_plucker = Pluckers::Base.new scope.where(
                klass_reflection.foreign_key => @results.map{|_, r| r[klass_reflection.active_record_primary_key.to_sym] }
              ),
              reflection

            # Now we create the _ids attribute for each result
            ids_reflection_name = "#{name.to_s.singularize}_ids".to_sym

            @results.each do |_, result|
              result[ids_reflection_name] ||= []
            end


            reflection_plucker.pluck.each do |r|
              @results.
                each do |_,result|
                  # For each related result (Author) we search those records
                  # (BlogPost) that are related (author.id == post.author_id) and
                  # insert the id in the _ids array
                  if result[klass_reflection.active_record_primary_key.to_sym] == r[klass_reflection.foreign_key.to_sym]
                    result[ids_reflection_name] << r[klass_reflection.active_record_primary_key.to_sym]
                  end
                end
            end

          end

        end

      end
    end
  end
end
