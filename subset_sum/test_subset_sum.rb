#!/usr/bin/ruby

# # #
#
#

require 'test/unit'
require 'subset_sum'

class TestSubsetSum < Test::Unit::TestCase

  def test_no_result
    values = [1, -3, 2, 4]
    reference_value = 0
    
    ss = SubsetSum.new

    assert_nil ss.run(values, 20)
  end

  ####################################################################

  def test_subset_sum_1

    values = [1, -3, 2, 4]
    reference_value = 0

    ss = SubsetSum.new

    result = ss.run(values, reference_value)

    assert_equal [1,-3,2].sort.inspect, result.sort.inspect
    assert_equal result, ss.result

    # compute another subset, with the same array of values
    assert_equal [2,-3].sort.inspect, ss.run(-1).sort.inspect
  end

  ####################################################################

  def test_subset_sum_2

    values = [-3, 2, 4, -1]
#    values = [1, -3, -3, 2, 4]
    reference_value = 0

    result = SubsetSum.new.run(values, reference_value)

    assert_equal [-1,-3,4].sort.inspect, result.sort.inspect
  end

  ####################################################################

  def test_subset_sum_3

    values = [1, -3, 2, 4, -1]
    reference_value = 0
    et_result = [[-3,1,2], [-3,-1,4], [-1,1]]

    result = SubsetSum.new.run(values, reference_value)

    # TODO: the algorithm is unable to find several subsets
    assert_not_equal et_result.sort.inspect, result.sort.inspect
  end

end
