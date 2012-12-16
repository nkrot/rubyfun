#
# Recursive implementation of the algorithm for solving Magic Square Game
#
# A magic square is a square with numbers 1.. arranged in such a way
# that the sum over each row, column and diagonal is the same.
#  for a 3x3 square the sum is 15;
#  for a 4x4 square the sum is 34.
#
#  4 | 3 | 8
# ---+---+---
#  9 | 5 | 1
# ---+---+---
#  2 | 7 | 6
#

# TODO
# 1. should find all solutions. can be implemented as Enumerator?
# 2. [+] should implement early pruning of unsuitable variants
#    + dont need to continue solving if the completed row does not sum
#      to the requested number
#    + same for every completed column
#    + same for the completed diagonals
#    + once all of the above were implemented, board.magic? is no longer
#      necessary, because all intermediate columns/rows/diagonals have
#      already been checked
# 3. should fill in the board in non-linear order but like this:
#    first row, first column, first diagonal
#    second row, second column, second diagonal

class MagicSquare
  attr_accessor :board
  attr_reader :solutions

  def initialize(nrows)
    if nrows.is_a? Integer
      @board = Board.new(nrows)
    elsif nrows.instance_of? Array
      @board = Board.new(nrows)
    end
    @solutions = []
  end

  ####################################################################

  def solve
    @free_numbers = Array.new(@board.ncells+1, true)
    solve_rec(0)
    @solutions
  end

  ####################################################################

  def solve_rec(idx)

#    # when last cell was filled in, take the final decision
#    if idx == @board.ncells
#      # the complete check is not necessary as long as all rows, columns
#      # and diagonals that were built at previous steps have already
#      # been checked. Replaced with the partial check.
##      if @board.magic?  #ok
#      if @board.partially_magic?(idx-1) #ok
#        @solutions << board.dup
#        return true
#      else
#        return false
#      end
#    end

    # Some solutions, thought incomplete yet, will not result in 
    # a correct complete solution. Prune them right now.
    # Here test whether the previous cell was filled with a suitable
    # number: if the cell ends a row, column or a diagonal (or all of them)
    # that row/column/diagonal should be magic.
    if @board.partially_magic?(idx-1)
      # if the end of the board was reached
      if idx == @board.ncells
        @solutions << @board.dup
        return true
      end
    else
      return false
    end

    # try filling the current cell with the numbers that have not yet
    # been used in other cells.
    1.upto(@board.ncells) do |num|
      unless used?(num)
        @board[idx] = use(num)
        if solve_rec(idx+1)
          return true
        else
          release(num) 
        end
      end
    end

    false
  end

  ####################################################################

  def to_s
    @board.to_s
  end

  def solution
    @solutions.first
  end

  def solved?
    ! @solutions.empty?
  end

  ########
  private
  ########

  def used?(num)
    ! @free_numbers[num]
  end

  def use(num)
    @free_numbers[num] = false
    num
  end

  def release(num)
    @free_numbers[num] = true
    num
  end

  ####################################################################
  ####################################################################
  ####################################################################

  class Board < Array
    attr_reader :nrows, :ncols, :template

    def initialize(nrows)
      if nrows.is_a? Array
        super(nrows)
        @nrows = @ncols = Math.sqrt(self.length).to_i
        unless @nrows * @ncols == self.length
          raise "Should be square :)"
        end
      else
        @nrows = @ncols = nrows
        super(@nrows**2)
      end

      @expected_sum = (1..ncells).inject(:+) / @nrows

      create_template
    end

    ####################################################################

    def dup
      Marshal.load(Marshal.dump(self))
    end

    def to_s
      @template % self
    end

    def ncells
      self.length
    end

    ####################################################################

    def each_row
      @nrows.times do |r|
        yield row(r)
      end
    end

    def each_column
      @ncols.times do |c|
        yield column(c)
      end
    end

    def each_diagonal
      yield primary_diagonal
      yield secondary_diagonal
    end

    ####################################################################

    def magic?
#      @expected_sum = inject(:+) / @nrows
      [:each_row, :each_column, :each_diagonal].each do |meth|
        self.send(meth) do |cells|
          return false  unless sum(cells) == @expected_sum
        end
      end
      true
    end

    ####################################################################
    # test if the row/column/diagonal that ends at the cell <idx>
    # is magic.
    # if no row/column/diagonal ends at this cell, return true

    def partially_magic?(idx)
      cells = []

      _idx = idx + 1 # as if cells are numbered from 1

      # if the cell ends a row
      if _idx >= @ncols && _idx % @ncols == 0
        r = idx / @nrows
        return false  unless sum(row(r)) == @expected_sum
      end

      # if the cell ends a column
      if _idx > ncells-ncols
        c = idx % @nrows
        return false  unless sum(column(c)) == @expected_sum
      end

      # if the cell ends the / diagonal
      if idx == ncells-ncols
        return false  unless sum(secondary_diagonal) == @expected_sum
      end

      # if the cell ends the \ diagonal
      if _idx == ncells
        return false  unless sum(primary_diagonal) == @expected_sum
      end

      true
    end

    ####################################################################

    # return i-th row
    def row(i)
      self[i*@ncols, @ncols]
    end

    # return i-th column
    def column(i)
      select_with_step(i, @ncols)
    end

    # return the main (primary) diagonal that goes \
    def primary_diagonal
      select_with_step(0, @ncols+1)
    end

    # return the antidiagonal (secondary diagonal) that goes /
    def secondary_diagonal
      select_with_step(@ncols-1, @ncols-1)
    end

    #######
    private
    #######

    def select_with_step(start, step)
      cells = []
      @nrows.times do
        cells << self[start]
        start += step
      end
      cells
    end

    def sum(arr)
#      puts arr.inspect
      arr.inject(:+)
    end

    ####################################################################
    # create template (on the left) that once filled in with values will
    # look like solved board (on the right)
    #
    #   %s | %s | %s       4 | 3 | 8
    #   ---+---+---       ---+---+---
    #   %s | %s | %s       9 | 5 | 1
    #   ---+---+---       ---+---+---
    #   %s | %s | %s       2 | 7 | 6

    def create_template
      row = "\n %s" + " | %s" * (@ncols-1)
      sep = "\n---" + "+---"  * (@ncols-1)
      @template = (row + sep) * (@nrows-1) + row
      @template.sub!(/^\n/, "")
    end
  end
end

######################################################################

if __FILE__ == $0
  square = MagicSquare.new(5)
  square.solve
  puts "Solved? -- #{square.solved?}"
  puts "Magic? -- #{square.solution.magic?}"
  puts square.solution.to_s
end
