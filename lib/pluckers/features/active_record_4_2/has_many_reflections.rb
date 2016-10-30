require_relative '../base/has_many_reflections'

module Pluckers
  module Features
    module HasManyReflections

      def active_record_has_many_class
        ActiveRecord::Reflection::HasManyReflection
      end

      include Pluckers::Features::Base::HasManyReflections

    end
  end
end
