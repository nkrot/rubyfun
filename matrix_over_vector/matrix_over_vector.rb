#
# treat a vector (unidimensional array) as a matrix
#

# TODO: convert to a mixin?

class MatrixOverVector

  attr_accessor :nrows, :ncols

  def initialize(obj, nrows, ncols=nil)
    if obj.is_a? Array
      @data  = obj
      @nrows = nrows
      @ncols = @data.length / @nrows
      if ncols && ncols != @ncols
        raise "Ooops. The real number of columns #{@ncols} does not match the one supplied to the constructor #{ncols}"
      end
    else
      raise "Not supported"
    end
  end

  ##################################################################
  # getters for individual rows, columns or diagonals

  def row(i)
    if i > -1 && i < @nrows
      @data[i*@ncols, @ncols]
    end
  end

  def column(i)
    if i > -1 && i < @ncols
      select_with_step(i, @ncols, @nrows)
    end
  end
  alias col column

  # diagonal that goes from top to bottom right
  def diagonal2br(i)
    c = to_col(i)
    i = to_linear_index(i)
    step = @ncols+1

    # TODO: the 3rd param has incorrect value for diagonals that go from
    # the leftmost column -- it always equals to @ncols-0.
    # To fix the behaviour, need to compute how many _rows_ are left
    # (fixed within select_with_step)
    # For diagonals that start at the topmost row the value is correct --
    # it is the number of columns that are left
    select_with_step(i, step, @ncols-c)
  end

  # diagonal that goes from top to bottom left
  def diagonal2bl(i)
    c = to_col(i)
    i = to_linear_index(i)
    step = @ncols-1

    # TODO: see comments to diagonal2br
    select_with_step(i, step, c+1)
  end

  ##################################################################
  #
  # iterators over rows, columns and diagonals
  #

  def each_row
    1.upto(@nrows) do |i|
      yield row(i-1)
    end
  end

  def each_column
    1.upto(@ncols) do |i|
      yield column(i-1)
    end
  end
  alias each_col each_column

  def each_diagonal(&block)
    each_diagonal2br(&block)
    each_diagonal2bl(&block)
  end

  def each_diagonal2bl
    # all diagonals that start at the topmost row
    0.upto(@ncols-1) do |c|
      yield diagonal2bl([0,c])
    end
    # all diagonals that start at the rightmost column
    1.upto(@nrows-1) do |r|
      yield diagonal2bl([r,@ncols-1])
    end
  end

  def each_diagonal2br
    # all diagonals that start at the topmost row
    0.upto(@ncols-1) do |c|
      yield diagonal2br([0,c])
    end
    # all diagonals that start at the leftmost column
    1.upto(@nrows-1) do |r|
      yield diagonal2br([r,0])
    end
  end

  ##################################################################
  #
  # converters of coordinates
  #

  # if i is an array [row, col], convert it to the index in
  # a linear sequence
  def to_linear_index(i)
    i.is_a?(Array) ? (i[0] * @ncols + i[1]) : i
  end

  # if i is an array [row,col], simply return col
  # if it is a number (position in a linear sequence), return corresponding
  # column number
  def to_col(i)
    i.is_a?(Array) ? i[1] : (i+@ncols) % @ncols
  end

  ####################################################################
  # collect given number of cells (<this_many>), going with the step <step>
  # from cell <start>

  private
  def select_with_step(start, step, this_many)
#    puts "select with step (#{start}, #{step}, #{this_many})"
    cells = []
    this_many.times do
      cells << @data[start]
      start += step
      break if start >= @data.length # TODO: oops, can avoid it?
    end
    cells
  end

end

######################################################################
# USAGE: ruby ./matrix_over_vector.rb

if __FILE__ == $0

  table = "\
ABCDE
FGHIJ
KLMNO
PQRST
UVWXY"

  puts "Given a 5x5 table:\n#{table}"

  letters = table.delete("\n").split("")
  matrix = MatrixOverVector.new(letters, 5)
  
  puts "Its rows are:"
  matrix.each_row do |row|
    puts row.inspect
  end

  puts "Its columns are:"
  matrix.each_column do |col|
    puts col.inspect
  end

  puts "All its diagonals (going to bottom right) are:"
  matrix.each_diagonal2br do |dgl|
    puts dgl.inspect
  end

  puts "All its diagonals (going to bottom left) are:"
  matrix.each_diagonal2bl do |dgl|
    puts dgl.inspect
  end

end

