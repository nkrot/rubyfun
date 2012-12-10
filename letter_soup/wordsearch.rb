#!/usr/bin/env ruby

# # #
# USAGE: wordsearch.rb puzzle.1.txt
#

class Puzzle
  attr_accessor :debug
  attr_accessor :board, :solved

  def initialize(lines)
    @debug = false
    @targets = []

    @board = Board.new(lines)
  end

  ####################################################################

  def solve(words)
    get_search_words(words)

    @board.each_row do |row|
      verboser "Checking row: #{row.inspect}"
      find_words(row)
    end
    
    @board.each_column do |col|
      verboser "Checking column: #{col.inspect}"
      find_words(col)
    end

    @board.each_diagonal do |dgl|
      verboser "Checking diagonal: #{dgl.inspect}"
      find_words(dgl)
    end

    @board.flip_cells
  end

  ####################################################################
  # Find words in the given set (array) of cells
  #
  # TODO
  # what of words intersect:
  #  ruby vs. bypass
  #  bypass vs. ass

  private
  def find_words(cells)
    @targets.each do |word|
      len = word.length

      if len > cells.length
        next
      end

      cells.each_index do |s|
        # s - start
        _cells = cells[s,len]
        if equal?(_cells, word)
          verboser "FOUND: #{_cells.inspect}"
          _cells.each {|cell| cell.hide}
        end
      end
    end
  end

  ####################################################################
  # check if the current set of cells equals to the given word

#  def equal?(cells, word)
#    unless cells.length == word.length
#      return false
#    end
#
#    # convert the set of cells to string and compare against the word
#    cells.map {|cell| cell.value}.join("") == word
#  end

  def equal?(cells, word)
    cells.length == word.length &&
    cells.map {|cell| cell.value}.join("") == word
  end

  ####################################################################
  # targets to search for is a list of words
  #  * in uppercase, to search case-insensitively
  #  * in both direct and reverse spellings (ruby, ybur)
  #  - NOT IMPLEMENTED:
  #    sorted from longest to shortest in order to give preference to
  #    longer words (if there are both ROCKS and ROCK, the first one
  #    should be preferred)
  #
  # in:  [ruby, dan, rocks, matz]
  # out: ["ROCKS", "SKCOR", "RUBY", "ZTAM", "MATZ", "YBUR", "DAN", "NAD"]

  private
  def get_search_words(words)
    @targets = words.map {|w|
      [w.upcase, w.upcase.reverse]
    }.flatten.sort_by {|w|
      -w.length
    }
    verboser @targets.inspect
  end

  def verboser(msg)
    if @debug
      puts msg
    end
  end
end

######################################################################

class Puzzle
  class Board

    def initialize(lines)
      @board = lines.map do |line|
        line.chomp.split.map do |ch|
          Cell.new(ch)
        end
      end
    end

    def to_s
      @board.map {|row|
        row.map {|ch| ch.to_s}.join(' ')
      }.join("\n")
    end

    # number of rows in the board
    def nrows
      @board.length
    end

    # number of columns in the board
    def ncols
      @board.first.length
    end

#    def dup
#      Marshal.load(Marshal.dump(self))
#    end

#    def reset
#      @board.map! do |row|
#        row.gsub(/./, "+")
#      end
#    end

    def each_row
      @board.each do |row|
        yield row
      end
    end

    def each_column
      @board.first.each_index do |i|
        yield column(i)
      end
    end

    def column(i)
      @board.map {|row| row[i]}
    end

    def each_diagonal
      # scan the leftmost and the rightmost columns downwards
      0.upto(nrows-1) do |r|
        yield diagonal2br(r, 0)
        yield diagonal2bl(r, ncols-1)
      end

      # scan the first row from left to right
      1.upto(ncols-2) do |c|
        yield diagonal2bl(0, c) # to bottom left
        yield diagonal2br(0, c) # to bottom right
      end
    end

    # get the diagonal that goes in the bottom left direction (/)
    def diagonal2bl(x,y)
      cells = []
      while x < nrows && y > -1
        cells << cell(x,y)
        x += 1
        y -= 1
      end
      cells
    end

    # get the diagonal that goes in the bottom right direction (\)
    def diagonal2br(x,y)
      cells = []
      while x < nrows && y < ncols
        cells << cell(x,y)
        x += 1
        y += 1
      end
      cells
    end

    def cell(r,c)
      @board[r][c]
    end

    def each_cell
      each_row do |row|
        row.each do |cell|
          yield cell
        end
      end
    end

    def flip_cells
      each_cell {|cell| cell.flip}
    end
  end

  class Cell #< String
    attr_accessor :value, :state

    def initialize(val, state=:visible)
      @value = val
      @state = state
    end

    def hide
      @state = :hidden
    end

    def unhide
      @state = :visible
    end

    def to_s
       visible? ? value : "+"
    end

    def visible?
      @state == :visible
    end

    def flip
      visible? ? hide : unhide
    end
  end
end

######################################################################

ARGV.each do |fname|
  lines = File.readlines(fname)

  words = lines.shift.split
  unless words.shift == "words:"
    $stderr.puts "No words to find specified in the 1st line of #{fname}"
    next
  end

  # the rest of lines are the puzzle
  puzzle = Puzzle.new(lines)
  puzzle.debug = !true # turn me on if you dare

#  puts "Initial state of the board:"
#  puts puzzle.board

  puzzle.solve(words)

#  puts "Solved puzzle:"
  puts puzzle.board
end

