$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'byebug'
require 'pluckers'
require 'dummy/dummy'
require_relative 'matchers/pluck_matcher.rb'

require 'minitest/autorun'

def active_record_version
  ActiveRecord.respond_to?(:version) ? ActiveRecord.version : Gem::Version.new(ActiveRecord::VERSION::STRING)
end

require 'minitest/matchers_vaccine' if active_record_version > Gem::Version.new("4.1")

def test_base_class
  active_record_version = ActiveRecord.respond_to?(:version) ? ActiveRecord.version : Gem::Version.new(ActiveRecord::VERSION::STRING)
  (active_record_version > Gem::Version.new("4.1") || active_record_version < Gem::Version.new("4.0")) ? Minitest::Test : Minitest::Unit::TestCase
end


if (active_record_version < Gem::Version.new("4.1"))

  def must matcher
    matcher.matches?(@subject)
  end
end
