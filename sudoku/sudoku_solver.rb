#
# class SudokuSolver --
#
#
# USAGE: see at the bottom of the file
#

#require 'pp'

class SudokuSolver

  attr_reader :results

  def initialize()
    @puzzle = nil # puzzle (the grid)
    @results = [] # Array of solved puzzles

    @level = 0 # recursion level, for debug purposes

    @grid_template = "\
%s %s %s |%s %s %s |%s %s %s
%s %s %s |%s %s %s |%s %s %s
%s %s %s |%s %s %s |%s %s %s
------+------+------
%s %s %s |%s %s %s |%s %s %s
%s %s %s |%s %s %s |%s %s %s
%s %s %s |%s %s %s |%s %s %s
------+------+------
%s %s %s |%s %s %s |%s %s %s
%s %s %s |%s %s %s |%s %s %s
%s %s %s |%s %s %s |%s %s %s"

  end
  
  ####################################################################

  def run(puzzle)
    clear
    parse(puzzle)
    solve
    return results
  end

  ####################################################################

  def parse(str)
    # multiline representation
    str = str.gsub(/[.]/, "0").gsub(/[^0-9]/, "")

    # one-line representation
    @puzzle = str.split('')
    @puzzle.collect! {|v| v.to_i}
    
    unless @puzzle.length == 81
      raise "Invalid sudoku puzzle"
    end
  end

  ####################################################################
  # clear the state

  def clear
    @puzzle = nil
    @results.clear
  end

  ####################################################################
  #

  def solve
#    @level += 1
#    puts "PUZZLE (level #{@level})\t#{@puzzle}"

    # numbers that are unsuitable for the jth unit, because
    # these numbers are in other units related to the jth unit
    unfit_numbers = {}

    # try to solve starting from each unit (cell) in the puzzle.
    # there are 81 units...
    81.times do |j|
      # if a unit is already solved (has a digit)
      next if @puzzle[j] != 0

#      puts "Solving unit ##{j} = #{@puzzle[j]}"

      # find numbers that can not be used in the unit being solved 
      # (which is jth unit) because these numbers are in other
      # units (which are kth units) that relate to the jth unit.
      80.times do |k|
        number = 0 # 0 for 'unsolved'
        if \
          # j and k are in the same row
          j/9 == k/9 || \
          # j and k are in the same column
          j%9 == k%9 || \
          # j and k are in the same 9x9 box
          j/27 == k/27 && j%9/3 == k%9/3 
        then
          number = @puzzle[k]
        end
        unfit_numbers [number] = true
      end

#      puts "UNFIT_NUMBERS: #{unfit_numbers.to_a.sort.inspect}"

      1.upto(9) do |n|
        next  if unfit_numbers.key?(n)
        # assume the current unit solved
        @puzzle[j] = n
        # try to solve the next unit
        solve
      end

#      @level -= 1

      # unsolve the unit to try another number
      return @puzzle[j] = 0
    end

    # we get here when all 81 units have been assigned a number
    @results << @puzzle.join("")
  end

  ####################################################################

  def to_grid(str)
    @grid_template % str.split('')
  end
end

######################################################################

if __FILE__ == $0
  puzzle   = "003020600900305001001806400008102900700000008006708200002609500800203009005010300"
  solution = "483921657967345821251876493548132976729564138136798245372689514814253769695417382"

  ss = SudokuSolver.new()
  results = ss.run(puzzle)
	
  if results.length == 1 && solution == results[0]
    puts "Selftest succeeded: one puzzle has been solved"
  else
    puts "Oops. Failed to solve the puzzle:\#{puzzle}"
  end
end

######################################################################
