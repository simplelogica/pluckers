require 'test_helper'

class PluckersTest < test_base_class
  def test_that_it_has_a_version_number
    refute_nil ::Pluckers::VERSION
  end

  def test_dummy_models_are_loaded
    assert_nil BlogPost.first
  end
end
