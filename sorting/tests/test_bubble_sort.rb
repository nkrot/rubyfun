#!/usr/bin/ruby

require 'test/unit'
require '../lib/bubble_sort'

class TestBubbleSort < Test::Unit::TestCase

  def setup
    @bs = BubbleSort.new
  end

  def test_sort_numbers
    before = [25,13,31,68,2,10,9,-3]
    sorted = [-3,2,9,10,13,25,31,68]

    assert_equal sorted, @bs.sort(before)
  end

  def test_sort_sorted_numbers
    sorted  = [-3,2,9,10,13,25,31,68]
    assert_equal sorted, @bs.sort(sorted)
  end

  def test_sort_inverted
    sorted  = [-3,2,9,10,13,25,31,68]
    inverted = sorted.reverse
    assert_equal sorted, @bs.sort(inverted)
  end

  def test_sort_same_numbers
    sorted  = [1,1,1,1]
    assert_equal sorted, @bs.sort(sorted)
  end

  def test_sort_almost_sorted_array
    before  = [2,3,4,5,1]
    sorted  = [1,2,3,4,5]
    assert_equal sorted, @bs.sort(before)
  end

  def test_sort_desc_numbers
    before = [25,13,31,68,2,10,9,-3]
    sorted = [68,31,25,13,10,9,2,-3]

    assert_equal sorted, @bs.sort_desc(before)
  end

  def test_sort_asc_numbers
    before = [25,13,31,68,2,10,9,-3]
    sorted = [-3,2,9,10,13,25,31,68]

    assert_equal sorted, @bs.sort_asc(before)
  end

  def test_sort_by_evenness
    before = [25,13,68,31,2,10,9,-3] # changed

    bs = BubbleSort.new

    bs.sorts_before = Proc.new {|a,b| a.even?}
    sorted = [68,2,10, 31,9,-3,25,13]

    # TODO: try me
#    bs.sorts_before = Proc.new {|a,b| a.even? && b.odd?}
#    sorted = [2,10,68, 31,9,-3,25,13]

    assert_equal sorted, bs.sort_asc(before)
  end

  def test_sort_by_evenness_keeping_original_order
    before = [25,68,13,31,2,9,-3,10] # changed

    bs = BubbleSort.new

    # does not alter the ordering among the odd and
    # among the even numbers
    bs.sorts_before = Proc.new {|a,b|
      a.even? || a.odd? && b.odd? }
    sorted = [68,2,10,  25,13,31,9,-3]

    assert_equal sorted, bs.sort_asc(before)
  end

  def test_sort_with_block__numbers
    # should behave equally
    bs1 = BubbleSort.new
    bs2 = BubbleSort2.new

    before = [25,13,31,68,2,10,9,-3]
    sorted_asc = [-3,2,9,10,13,25,31,68]
    sorted_desc = sorted_asc.reverse

    # BubbleSort
    assert_equal sorted_asc,  bs1.sort(before) {|a,b| a < b }
    assert_equal sorted_desc, bs1.sort(before) {|a,b| a > b }
    assert_equal sorted_desc, bs1.sort(before) {|a,b| b < a }
    # BubbleSort2
    assert_equal sorted_asc,  bs1.sort(before) {|a,b| a < b }
    assert_equal sorted_desc, bs1.sort(before) {|a,b| a > b }
    assert_equal sorted_desc, bs1.sort(before) {|a,b| b < a }

    # without explicit block, assume ascending order
    assert_equal sorted_asc,  bs1.sort(before)
    assert_equal sorted_asc,  bs2.sort(before)
  end

  def test_sort_with_block__strings_by_length
    strings = %w[I love tagging and parsing such tiny sentences]
    sorted  = %w[sentences tagging parsing tiny love such and I]

    assert_equal sorted, @bs.sort(strings) {|a,b| a.length > b.length}
  end
end
