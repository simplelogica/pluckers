require_relative '../base/has_one_reflections'

module Pluckers
  module Features
    module HasOneReflections

      def active_record_has_one_reflection? reflection
        reflection.is_a? ActiveRecord::Reflection::HasOneReflection
      end

      include Pluckers::Features::Base::HasOneReflections


    end
  end
end
