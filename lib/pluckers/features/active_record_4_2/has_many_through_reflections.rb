require_relative '../base/has_many_through_reflections'

module Pluckers
  module Features
    module HasManyThroughReflections

      def active_record_has_many_through_class
        ActiveRecord::Reflection::ThroughReflection
      end

      include Pluckers::Features::Base::HasManyThroughReflections


    end
  end
end
