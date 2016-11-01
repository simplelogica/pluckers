$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'byebug'
require 'pluckers'
require 'dummy/dummy'
require_relative 'matchers/pluck_matcher.rb'

require 'minitest/autorun'
require 'minitest/matchers_vaccine' if ActiveRecord.version > Gem::Version.new("4.1")

def test_base_class
  (ActiveRecord.version > Gem::Version.new("4.1")) ? Minitest::Test : Minitest::Unit::TestCase
end

if (ActiveRecord.version < Gem::Version.new("4.1"))

  def must matcher
    matcher.matches?(@subject)
  end
end
