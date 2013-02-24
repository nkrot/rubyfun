#!/usr/bin/ruby

require 'test/unit'
require '../lib/merge_sort'

class TestCocktailSort < Test::Unit::TestCase

  def setup
    @sorter = MergeSort.new
  end

  def test_sort_numbers
    before = [25,31,13,68,2,10,9,-3]
    sorted = [-3,2,9,10,13,25,31,68]

    assert_equal sorted, @sorter.sort(before)
  end

  def test_sort_sorted_numbers
    sorted  = [-3,2,9,10,13,25,31,68]
    assert_equal sorted, @sorter.sort(sorted)
  end

  def test_sort_inverted
    sorted  = [-3,2,9,10,13,25,31,68]
    inverted = sorted.reverse
    assert_equal sorted, @sorter.sort(inverted)
  end

  def test_sort_same_numbers
    sorted  = [1,1,1,1]
    assert_equal sorted, @sorter.sort(sorted)
  end

  def test_sort_almost_sorted_array
    before  = [2,3,4,5,1]
    sorted  = [1,2,3,4,5]
    assert_equal sorted, @sorter.sort(before)
  end

  def test_empty_array
    assert_equal [], @sorter.sort([])
  end

  def test_merge
    ms = MergeSort.new

    # can not call a private method
#    assert_equal [1,2,3,4],     ms.merge([1,2], [3,4])
#    assert_equal [1,2,3,4],     ms.merge([3,4], [1,2])
#    assert_equal [1,2,3,4,5,6], ms.merge([3,4,6], [1,2,5])

    # Object#send(:method, arg1, arg2...) breaks privateness
    assert_equal [1,2,3,4],     ms.send(:merge, [1,2], [3,4])
    assert_equal [1,2,3,4],     ms.send(:merge, [3,4], [1,2])
    assert_equal [1,2,3,4,5,6], ms.send(:merge, [3,4,6], [1,2,5])
  end
end

