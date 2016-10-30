require_relative '../base/has_one_through_reflections'

module Pluckers
  module Features
    module HasOneThroughReflections

      def active_record_has_one_through_class
        ActiveRecord::Reflection::ThroughReflection
      end

      include Pluckers::Features::Base::HasOneThroughReflections


    end
  end
end
