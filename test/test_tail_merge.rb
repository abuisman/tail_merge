# frozen_string_literal: true

require "test_helper"

class TestTailMerge < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::TailMerge::VERSION
  end

  def test_merges_classes_without_conflicts
    expected = "hover:bg-dark-red p-3 bg-[#B91C1C]"

    assert_equal expected, TailMerge.merge(%w[px-2 py-1 bg-red hover:bg-dark-red p-3 bg-[#B91C1C]])
  end

  def test_splits_string_classes_into_array
    expected = "hover:bg-dark-red p-3 bg-[#B91C1C]"

    assert_equal expected, TailMerge.merge("px-2 py-1 bg-red hover:bg-dark-red p-3 bg-[#B91C1C]")
  end
end
