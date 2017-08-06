require_relative '../base/belongs_to_polymorphic_reflections'

module Pluckers
  module Features
    module BelongsToPolymorphicReflections

      def active_record_belongs_to_polymorphic_reflection? reflection
        reflection.is_a?(ActiveRecord::Reflection::BelongsToReflection) &&
          reflection.options[:polymorphic]
      end

      include Pluckers::Features::Base::BelongsToPolymorphicReflections

    end
  end
end
