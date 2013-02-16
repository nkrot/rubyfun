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
    assert sorted, @bs.sort(inverted)
  end

  def test_sort_same_numbers
    sorted  = [1,1,1,1]
    assert sorted, @bs.sort(sorted)
  end

end
