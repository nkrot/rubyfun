#!/usr/bin/ruby

require 'test/unit'
require 'magic_square'

class TestMagicSquare < Test::Unit::TestCase

  @@solutions = \
  [
   MagicSquare::Board.new([2,7,6,  9,5,1,  4,3,8]),
   MagicSquare::Board.new([4,3,8,  9,5,1,  2,7,6])
  ]

  def self.solutions
    @@solutions
  end

  def test_new_with_size
    square = MagicSquare.new(3)
  end

  def test_solve_empty
    square = MagicSquare.new(3)
    square.solve
    assert square.solved?
  end

  def test_solve_partial
  end

  def test_find_all_solutions
  end
end

######################################################################

class TestMagicSquareBoard < Test::Unit::TestCase

  def test_new_with_size
    board = MagicSquare::Board.new(3)
    assert_equal 3, board.nrows
    assert_equal 3, board.ncols
  end

  def test_new_with_array
    board = MagicSquare::Board.new([1,2,3,4,5,6,7,8,9])
    assert_equal 3, board.nrows
    assert_equal 3, board.ncols
  end

  def test_to_s_3x3
    et_rows = [ [1,2,3], [4,5,6], [7,8,9]]
    board = MagicSquare::Board.new(et_rows.flatten)

etalon = "\
 1 | 2 | 3
---+---+---
 4 | 5 | 6
---+---+---
 7 | 8 | 9"

    assert_equal etalon, board.to_s
  end

  def test_each_row_in_3x3
    et_rows = [ [1,2,3], [4,5,6], [7,8,9]]
    board = MagicSquare::Board.new(et_rows.flatten)
    
    rows = []
    board.each_row do |row|
      rows << row
    end

    assert_equal et_rows, rows
  end

  def test_each_column_in_3x3
    et_rows = [ [1,2,3], [4,5,6], [7,8,9]]
    et_cols = et_rows.transpose
    board = MagicSquare::Board.new(et_rows.flatten)
    
    cols = []
    board.each_column do |col|
      cols << col
    end

    assert_equal et_cols, cols
  end

  def test_each_diagonal_in_3x3
    et_rows = [ [1,2,3], [4,5,6], [7,8,9]]
    et_diagonals = [[1,5,9], [3,5,7]]

    board = MagicSquare::Board.new(et_rows.flatten)
    
    diagonals = []
    board.each_diagonal do |diag|
      diagonals << diag
    end

    assert_equal et_diagonals, diagonals
  end

  def test_each_diagonal_in_4x4
    et_rows = [ [1,2,3,33], [4,5,6,66], [7,8,9,99],  [4,3,2,11]]
    et_diagonals = [[1,5,9,11], [33,6,8,4]]

    board = MagicSquare::Board.new(et_rows.flatten)
    
    diagonals = []
    board.each_diagonal do |diag|
      diagonals << diag
    end

    assert_equal et_diagonals, diagonals
  end

  def test_magic?
    TestMagicSquare::solutions.each do |board|
      assert board.magic?
    end

    et_rows = [[4,3,1], [9,5,8], [2,7,6]]
    board = MagicSquare::Board.new(et_rows.flatten)
    assert !board.magic?
  end
end

