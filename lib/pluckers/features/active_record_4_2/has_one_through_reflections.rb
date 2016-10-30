require_relative '../base/has_one_through_reflections'

module Pluckers
  module Features
    module HasOneThroughReflections

      def active_record_has_one_through_reflection? reflection
        reflection.is_a?(ActiveRecord::Reflection::ThroughReflection) &&
        reflection.delegate_reflection.is_a?(ActiveRecord::Reflection::HasOneReflection)
      end

      include Pluckers::Features::Base::HasOneThroughReflections


    end
  end
end
