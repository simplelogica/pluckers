require_relative '../base/has_many_through_reflections'

module Pluckers
  module Features
    module HasManyThroughReflections

      def active_record_has_many_through_reflection? reflection
        reflection.is_a?(ActiveRecord::Reflection::ThroughReflection) &&
        (reflection.macro == :has_many)
      end

      include Pluckers::Features::Base::HasManyThroughReflections


    end
  end
end
