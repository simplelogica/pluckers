require_relative '../base/has_and_belongs_to_many_reflections'

module Pluckers
  module Features
    module HasAndBelongsToManyReflections

      def active_record_has_and_belongs_to_many_reflection? reflection
        reflection.is_a?(ActiveRecord::Reflection::AssociationReflection) &&
        (reflection.macro == :has_and_belongs_to_many)
      end

      include Pluckers::Features::Base::HasAndBelongsToManyReflections

    end
  end
end
