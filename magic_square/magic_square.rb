#
#
# TODO
# 1. should find all solutions. can be implemented as Enumerator?
# 2. should implement early pruning of unsuitable variants
#    * dont need to continue solving if the completed row does not sum
#      to the requested number
#    * same for the every completed column
#    * same for the completed / diagonal

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

    if idx == @board.ncells
      if @board.magic?
        @solutions << board.dup
        return true
      else
        return false
      end
    end

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

      create_template
    end

    def dup
      Marshal.load(Marshal.dump(self))
    end

    def to_s
      @template % self
    end

    def ncells
      self.length
    end

    def each_row
      @nrows.times do |r|
        yield self[r*@ncols, @ncols]
      end
    end

    def each_column
      @ncols.times do |c|
        yield select_with_step(c, @ncols)
      end
    end

    def each_diagonal
      yield select_with_step(0, @ncols+1) # \
      yield select_with_step(@ncols-1, @ncols-1) # /
    end

    def magic?
      expected_sum = inject(:+) / @nrows

      [:each_row, :each_column, :each_diagonal].each do |meth|
        self.send(meth) do |row|
          return false  unless sum(row) == expected_sum
        end
      end
      
      true
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
      arr.inject(:+)
    end

    ####################################################################
    # create template (on the left) that once filled in with values will
    # look like solved board (on the right)
    #
    #   %s | %s | %s       1 | 2 | 3
    #   ---+---+---       ---+---+---
    #   %s | %s | %s       4 | 5 | 6
    #   ---+---+---       ---+---+---
    #   %s | %s | %s       7 | 8 | 9

    def create_template
      row = "\n %s" + " | %s" * (@ncols-1)
      sep = "\n---" + "+---"  * (@ncols-1)
      @template = (row + sep) * (@nrows-1) + row
      @template.sub!(/^\n/, "")
    end
  end
end

if __FILE__ == $0
  square = MagicSquare.new(3) # NOTE: it takes a goooood white to solve 4x4
  square.solve
  puts "Solved? -- #{square.solved?}"
  puts square.solution.to_s
end
