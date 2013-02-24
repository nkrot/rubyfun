#!/usr/bin/ruby

require 'test/unit'
require '../lib/cocktail_sort'

class TestCocktailSort < Test::Unit::TestCase

  def setup
    @sorter = CocktailSort.new
  end

  def test_sort_numbers
    before = [25,13,31,68,2,10,9,-3]
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
end

