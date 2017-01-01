##
# This module includes the pluck method that is used in the Minitest::Unit::TestCase
# classes.
#
# It simulates the pluck with regular AR objects and then compares with the
# real plucked information.
module PluckMatcher

  ##
  # The method call inside any minitest test: must(pluck(block to replace the pluck)).
  #
  # The argument is a proc that will be executed for every fetched record and
  # creates the same hash that should be plucked with the pluckers.
  #
  # The records will be read from the plucker itself.
  def pluck record_block
    Matcher.new record_block
  end

  class Matcher

    def initialize record_block
      @record_block = record_block
    end

    def description
      "the information plucked must be the same as the one in the original records"
    end

    def matches? plucker
      @plucked = plucker.pluck
      @built = plucker.records.map{|r| @record_block.call(r)}.to_a
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
