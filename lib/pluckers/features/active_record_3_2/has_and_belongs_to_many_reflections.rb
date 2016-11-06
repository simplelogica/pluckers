require_relative '../base/has_and_belongs_to_many_reflections'

module Pluckers
  module Features
    module HasAndBelongsToManyReflections

      def active_record_has_and_belongs_to_many_reflection? reflection
        reflection.is_a?(ActiveRecord::Reflection::AssociationReflection) &&
        (reflection.macro == :has_and_belongs_to_many)
      end

      def has_and_belongs_to_many_ids klass_reflection

        # First,  we get the the join table
        join_table = Arel::Table.new(klass_reflection.options[:join_table])

        # And now, the foreign_keys.
        # In our example with BlogPost and Category they would be:
        # model_foreign_key = blog_post_id
        # related_model_foreign_key = category_id
        model_foreign_key = klass_reflection.foreign_key
        related_model_foreign_key = klass_reflection.association_foreign_key

        # Now we query the join table so we get the two ids
        ids_query = join_table.where(
            join_table[model_foreign_key].in(@results.map{|_, r| r[:id] })
          ).project(
            join_table[related_model_foreign_key],
            join_table[model_foreign_key]
          )

        join_results = ActiveRecord::Base.connection.execute(ids_query.to_sql)

      end

      include Pluckers::Features::Base::HasAndBelongsToManyReflections

    end
  end
end
