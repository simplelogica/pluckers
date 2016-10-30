require_relative '../base/has_and_belongs_to_many_reflections'

module Pluckers
  module Features
    module HasAndBelongsToManyReflections

      def active_record_has_and_belongs_to_many_reflection? reflection
        reflection.is_a? ActiveRecord::Reflection::HasAndBelongsToManyReflection
      end

      include Pluckers::Features::Base::HasAndBelongsToManyReflections

    end
  end
end
