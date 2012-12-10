#!/usr/bin/ruby

require 'test/unit'
require 'decimal_dominant'

class TestDecimalDominant < Test::Unit::TestCase

  def test_no_solution_1
    dd_finder = DecimalDominant.new
    dd_finder.debug = !true

    items = [2, 1, 3, 10, 4, 5, 6, 8, 9, 7, 11, 12, 16, 15]
    res = []

    assert_equal(res, dd_finder.run_bf(items))
    assert_equal(res, dd_finder.run(items))
  end

  def test_no_solution_2
    dd_finder = DecimalDominant.new
    dd_finder.debug = !true

    # array of unique numbers from 0 upto 27 and two instance of 100
    #   [0, 1, ... 27, 100, 100]
    # the array contains no decimal dominant, the only repeating value
    # is 100 (occurs twice, but for it to be decimal dominant it must
    # occur > 3 times)
    items = (0..29).to_a
    items[28] = 100
    items[29] = 100
    
    res = []

#    puts items.inspect

    assert_equal(res, dd_finder.run_bf(items))
    assert_equal(res, dd_finder.run(items))
  end

  ####################################################################

  def test_one_solution
    dd_finder = DecimalDominant.new
    dd_finder.debug = !true

    items = [2, 1, 3, 1, 4, 5, 6, 8, 9, 7]
    res = [1]

    assert_equal(res, dd_finder.run_bf(items))
    assert_equal(res, dd_finder.run(items))
  end

  ####################################################################

  def test_two_solutions
    dd_finder = DecimalDominant.new
    dd_finder.debug = !true

    # initial array [0..99]
    items = (0...100).to_a
    # add a non dominant 9 (occurs 1+8 times)
    8.times {|i| items[80+i] = 9 }
    # add a non dominant 5 (occurs 1+9 times)
    9.times {|i| items[60+i] = 5 }
    # add a dominant 0 (occurs 1+10 times)
    10.times {|i| items[20+i] = 0 }
    # add a dominant 4 (occurs 1+15 times)
    15.times {|i| items[40+i] = 4 }

    res = [0, 4]

    assert_equal(res, dd_finder.run_bf(items))
    assert_equal(res, dd_finder.run(items))
  end
end
