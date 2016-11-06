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
      # This module implements plucking has_many :through relationships in a
      # recursive way.
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
      module HasOneThroughReflections


        ##
        # Here we obtain the has_many :through reflections to include in the pluck
        # operation and also include the relation foreign key in the attributes to
        # pluck for this model.
        def configure_query
          super

          pluck_reflections = @options[:reflections] || {}

          return if pluck_reflections.blank?

          @has_one_through_reflections = { }

          # We iterate through the class reflections passed as options
          @klass_reflections.slice(*pluck_reflections.keys).
          # And select those that are Through and which delegate reflection is a HasMany
            select{|_, r| active_record_has_one_through_reflection?(r)}.
          # And store them in the has_many_reflection hash that will be used later
            each do |name, reflection|
              name = name.to_sym
              @has_one_through_reflections[name] = pluck_reflections[name]
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

          return if @has_one_through_reflections.blank?

          @has_one_through_reflections.each do |name, reflection|
            # As an example we will imagine that we are plucking BlogPost and
            # this relation is the :user, that is a relationship through
            # Author

            # We get the meta information about the :through reflection (:user)
            klass_reflection = @klass_reflections[name]

            # And also the has_many reflection (:posts) as we will need it to fetch information
            reflection_to_pluck =  klass_reflection.chain.reverse.first

            # initialize some options such as the plucker or the scope of the pluck
            scope = reflection_to_pluck.klass.scoped

            # Essentially we are going to pluck the has_one relationship and
            # add the reflections option so it recursively plucks the has_one
            # :user reflection from BlogPost.
            plucker = reflection[:plucker] || Pluckers::Base
            plucker_options = {
              attributes: [reflection_to_pluck.active_record_primary_key.to_sym],
              reflections: { klass_reflection.source_reflection.name => reflection }
            }

            # In order to create this intermediary plucker we add a where to the
            # scope, so we filter the records to pluck as we only get those with
            # an id in the set of the foreign keys of the records already
            # plucked by the base plucker
            #
            # In our Example we would be doing something like
            # Author.all.where(id: author_ids)
            reflection_plucker = plucker.new scope.where(
                reflection_to_pluck.active_record_primary_key => @results.map{|_, r| r[reflection_to_pluck.foreign_key.to_sym] }
              ),
              plucker_options

            # We initialize so we return an empty array if there are no record
            # related
            @results.each do |_, result|
              result[name] ||= nil
            end

            reflection_plucker.pluck.each do |r|
              @results.each do |_,result|
                # For each related result (Author) we search those records
                # (BlogPost) that are related (author.id == post.author_id) and
                # insert not the record itself but the desired reflection in the
                # result
                if result[reflection_to_pluck.foreign_key.to_sym] == r[reflection_to_pluck.active_record_primary_key.to_sym]
                  result[name] = r[name]
                end
              end
            end
          end
        end
      end
    end
  end
end
