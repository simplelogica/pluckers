##
# This module includes the pluck method that is used in the Minitest::Test
# classes.
#
# It simulates the pluck with regular AR objects and then compares with the
# real plucked information.
module PluckMatcher

  ##
  # The method call inside any minitest test: must(pluck(records, block to replace the pluck)).
  #
  # The first argument is the AR scope that stores all the objects that will be
  # fetched in order to simulate the pluck.
  #
  # The second argument is a proc that will be executed for every fetched
  # record and creates the same hash that should be plucked with the pluckers.
  def pluck records, record_block
    Matcher.new records, record_block
  end

  class Matcher

    def initialize records, record_block
      @records = records
      @record_block = record_block
    end

    def description
      "the information plucked must be the same as the one in the original records"
    end

    def matches? plucker
      @plucked = plucker.pluck
      @built = @records.map{|r| @record_block.call(r)}.to_a
      @plucked == @built
    end

    def failure_message
      "expected to have plucked: #{@built.inspect}. Plucked #{@plucked.inspect} instead"
    end

    def failure_message_when_negated
      "expected not to have plucked: #{@plucked.inspect}."
    end
  end
end
