# frozen_string_literal: true

require "test_helper"

class TestTailMerge < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::TailMerge::VERSION
  end

  def test_merges_classes_without_conflicts
    expected = "hover:bg-dark-red p-3 bg-[#B91C1C]"

    assert_equal expected, TailMerge.merge(%w[px-2 py-1 bg-red hover:bg-dark-red p-3 bg-[#B91C1C]])

    instance = TailMerge.new
    assert_equal expected, instance.merge(%w[px-2 py-1 bg-red hover:bg-dark-red p-3 bg-[#B91C1C]])
  end

  def test_splits_string_classes_into_array
    expected = "hover:bg-dark-red p-3 bg-[#B91C1C]"

    assert_equal expected, TailMerge.merge("px-2 py-1 bg-red hover:bg-dark-red p-3 bg-[#B91C1C]")

    instance = TailMerge.new
    assert_equal expected, instance.merge("px-2 py-1 bg-red hover:bg-dark-red p-3 bg-[#B91C1C]")
  end

  def test_prefixes_classes
    expected = "tw-bg-green-200"

    assert_equal expected, TailMerge.merge("tw-bg-red-200 tw-bg-green-200", prefix: "tw-")

    instance_with_prefix = TailMerge.new(prefix: "tw-")
    assert_equal expected, instance_with_prefix.merge("tw-bg-red-200 tw-bg-green-200")

    expected = "hover:bg-dark-red p-3 bg-[#B91C1C]"
    assert_equal expected, TailMerge.merge(%w[px-2 py-1 bg-red hover:bg-dark-red p-3 bg-[#B91C1C]])

    instance_without_prefix = TailMerge.new
    assert_equal expected, instance_without_prefix.merge(%w[px-2 py-1 bg-red hover:bg-dark-red p-3 bg-[#B91C1C]])
  end

  def test_returns_single_string
    expected = "bg-green-200"

    assert_equal expected, TailMerge.merge("bg-green-200")

    instance = TailMerge.new
    assert_equal expected, instance.merge("bg-green-200")
  end

  def test_single_array_item_given_as_string
    expected = "bg-green-200"

    assert_equal expected, TailMerge.merge(["bg-green-200"])

    instance = TailMerge.new
    assert_equal expected, instance.merge(["bg-green-200"])
  end

  def test_empty_array_returns_empty_string
    expected = ""

    assert_equal expected, TailMerge.merge([])

    instance = TailMerge.new
    assert_equal expected, instance.merge([])
  end

  def test_empty_string_returns_empty_string
    expected = ""

    assert_equal expected, TailMerge.merge("")

    instance = TailMerge.new
    assert_equal expected, instance.merge("")
  end
end
