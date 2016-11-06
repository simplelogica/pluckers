require_relative '../base/belongs_to_reflections'

module Pluckers
  module Features
    module BelongsToReflections

      def active_record_belongs_to_reflection? reflection
        reflection.is_a?(ActiveRecord::Reflection::AssociationReflection) &&
        reflection.macro == :belongs_to
      end

      include Pluckers::Features::Base::BelongsToReflections

    end
  end
end
