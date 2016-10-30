require_relative '../base/belongs_to_reflections'

module Pluckers
  module Features
    module BelongsToReflections

      def active_record_belongs_to_class
        ActiveRecord::Reflection::BelongsToReflection
      end

      include Pluckers::Features::Base::BelongsToReflections

    end
  end
end
