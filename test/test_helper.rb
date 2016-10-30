$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'byebug'
require 'pluckers'
require 'dummy/dummy'
require_relative 'matchers/pluck_matcher.rb'

require 'minitest/autorun'
require 'minitest/matchers_vaccine'
