#
# class SubsetSum --
#    dynamic programming solution to the subset sum problem
#
# Goal:
#    In the given array find items that sum up to the given reference value.
#
# For example:
#    values = [1, -3, 2, 4]
#    reference_value = 0
#    result = [1, -3, 2] -- values that sum up to 0
#
# Note if several solutions are possible, the algorithm finds only one
#    values = [1, -3, 2, 4, -1]
#    reference_value = 0
#    result: [1, -3, 2] and [-3, 4, -1] and [1,-1]
#
# Found at:
#     http://www.skorks.com/2011/02/algorithms-a-dropbox-challenge-and-dynamic-programming/
#

#require 'pp'

class SubsetSum
  attr_reader :result, :matrix

  def initialize()
    @result = nil
    @matrix = nil

    @min = nil
    @max = nil
  end

  ####################################################################
  # Find subset if the given values #1 that sum up to the requested
  # reference value #2.
  #
  # Args
  #   #1 -- [OPTIONAL] array of values
  #         If not given, the values from the previous run are reused
  #   #2 -- reference value
  #
  # Return
  #   subset of values as Array
  #
  # TODO optimization
  # 1. Before populate_matrix() we can check if the requested reference
  #    value is possible (falls within @min..@max range).
  #    Even building of the initial matrix may not be necessary.
	
  def run(*args)

    if args.length == 2
      refvalue = args[1]

      initialize_matrix(args[0])
      # TODO: do range check here
      populate_matrix()

    elsif args.length == 1
      refvalue = args[0]

      unless @matrix
        # this situation may appear if the matrix was not built
        # at a previous run due to the range check
        initialize_matrix(args[0])
        # TODO: do range check here
        populate_matrix()
      end
    else
      raise "Invalid number of arguments given"
    end

    derive_subset(refvalue)

    return @result
  end

  ####################################################################
  # given the values 
  #   [1, -3, 2, 4]
  #
  # rows: indices in the array <values>
  # columns: every possible sum that can be made of given <values>
  #
  #      | #0 | #1 | #2 | #3 | #4 | #5 | #6 | #7 | #8 | #9 |#10 |#11 
  # +----+----+----+----+----+----+----+----+----+----+----+----+----+
  # | #0 |VAL | -3 | -2 | -1 | 0  | 1  | 2  | 3  | 4  | 5  | 6  | 7  | <-- labels
  # +----+----+----+----+----+----+----+----+----+----+----+----+----+
  # | #1 |  1 |    |    |    |    |    |    |    |    |    |    |    |
  # | #2 | -3 |    |    |    |    |    |    |    |    |    |    |    |
  # | #3 |  2 |    |    |    |    |    |    |    |    |    |    |    |
  # | #4 |  4 |    |    |    |    |    |    |    |    |    |    |    |
  # +----+----+----+----+----+----+----+----+----+----+----+----+----+
  #
  # the column 0 and the row 0 are auxiliary structures
  #  column 0 holds given values
  #  row 0 holds labels (= range within which all sums are possible)
  #

private
  def initialize_matrix(values)
    #
    # compute the maximal and the minimal sums that are possible
    # with the given values
    #
    @min = values.inject(0) {|sum, v|
#      puts "v/sum: #{v}/#{sum}"
      v < 0 ? sum + v : sum
    }

    @max = values.inject(0) {|sum, v|
#      puts "v/sum: #{v}/#{sum}"
      v > 0 ? sum + v : sum
    }

    labels = (@min..@max).to_a
#    puts "POSSIBLE SUMS: #{labels.inspect}"

    @matrix = []
    0.upto(values.length) {|i|
      # 0 marks impossible sum
      @matrix[i] = Array.new(labels.length+1, 0)
      @matrix[i][0] = values[i-1] # aux column 0
    }

    labels.unshift("VAL")

    @matrix[0] = labels # aux row 0
  end

  ####################################################################
  # Populate the matrix by marking cells that correspond to possible
  # sums that can be obtained from any combination of given numbers.
  #
  # The cells are marked by integers:
  #   0 -- the sum is impossible
  #   1 -- the rule #1 applies
  #   2 -- the rule #2 applies
  #   3 -- the rule #3 applies
  # The information on what rule applies to a cell is intended for
  # clarity and further debug only. In another implementation more
  # concise true|false values would be sufficient.
  #
  # DETAILS
  # -------
  # There are three rules that we use to mark matrix cells.
  # A cell is marked when the corresponding sum (column label) is
  # possible using the current value (represented by the row)
  #
  # 1. A value is per se a valid sum.
  #    Therefore, mark colums that correspond to the given <values>
  # 2. Once it is possible to obtain a sum using a subset of <value>
  #    looking at more values does not invalidate the existing sums
  #    Therefore, if a cell gets marked, mark all cells in the same
  #    column in the rows below.
  # 3. When a sum is possible adding another number creates a new
  #    possible sum.
  #    Therefore, mark a cell
  #    (3.1) compute the previous sum P
  #       P = current sum (=column label) - current value (=row label)
  #    (3.2) check that the previous sum P is possible according
  #      to the matrix by inspecting the cell that corresponds to
  #      the sum P (column label = P) in the row just above.
  #    This alogirthm is implemented in current_sum_possible? method
  #
  # Return
  #   nothing

  def populate_matrix()
#    pp @matrix

    # the first row
    # rule 1 applies only.
    @matrix[1].each_index {|col|
      # col -- column number
      next  if col == 0 # skip aux column

      if @matrix[1][0] == @matrix[0][col]
        @matrix[1][col] = 1 # rule 1
      end
    }

#    pp @matrix

    # other rows
    # all rules apply
    2.upto(@matrix.length-1).each {|row|
      @matrix[row].each_index {|col|
        case
        when col == 0
          # skip aux column
        when @matrix[row][0] == @matrix[0][col]
          @matrix[row][col] = 1 # rule 1
        when @matrix[row-1][col] > 0
          @matrix[row][col] = 2 # rule 2
        when current_sum_possible?(row,col)
          @matrix[row][col] = 3 # rule 3
        end
      }
    }

#    pp @matrix

    return true
  end

  ####################################################################
  # see algorithm description in the description of rule 3 in
  # the method populate_matrix()
  #

  def current_sum_possible?(row, col)
#    puts "Current cell #{row}/#{col}"

    # compute previous sum
#    puts "#{@matrix[0][col]} - #{@matrix[row][0]}"
    p = @matrix[0][col] - @matrix[row][0]
#    puts "previous sum =#{p}"

    #
    # check whether previous sum is possible
    #
    pcol = @matrix[0].index(p)

    return false  unless pcol

    return (@matrix[row-1][pcol] > 0)
  end

  ####################################################################
  # derive the subset of values that sum up to the given reference value.
  #
  # Args
  #   #1 -- reference value, for which to derive the subset
  #
  # Return
  #   true  if the sum is possible
  #   false if the sum is impossible
  # additionally:
  #   this method sets @result to the result of computation
  #
  # NOTE
  # if several solutions are possible, only one is found. we suck
	
  def derive_subset(rv)
#    pp @matrix

    # column that contains reference value <rv>
    col = @matrix[0].index(rv)

    return false  unless col

    @result = []

    # investigate rows in backward order (bottom-up)
    (@matrix.length-1).downto(1) {|row|
      if @matrix[row][col] == 0
        # we are done
        break
      elsif @matrix[row-1][col] > 0 && row > 1
        # if the previous row (except aux row) contains a possible
        # sum, switch to this row
        next
      else
        # the current value is suitable for obtaining
        # the requested reference value
        @result << @matrix[row][0]
        # previous sum
        p = @matrix[0][col] - @matrix[row][0]
        col = @matrix[0].index(p)
      end
    }

    return true
  end
end

