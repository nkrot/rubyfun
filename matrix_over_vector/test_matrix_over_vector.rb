#!/usr/bin/ruby

require 'matrix_over_vector'
require 'test/unit'

class TestMatrixOverVector < Test::Unit::TestCase
  @@table_str = "\
U E W R T R B H C D
C X G Z U W R Y E R
R O C K S B A U C U
S F K F M T Y S G E
Y S O O U N M Z I M
T C G P R T I D A N
H Z G H Q G W T U V
H Q M N D X Z B S T
N T C L A T N B C E
Y B U R P Z U X M S"

  @@rows = \
  [
   "UEWRTRBHCD",
   "CXGZUWRYER",
   "ROCKSBAUCU",
   "SFKFMTYSGE",
   "YSOOUNMZIM",
   "TCGPRTIDAN",
   "HZGHQGWTUV",
   "HQMNDXZBST",
   "NTCLATNBCE",
   "YBURPZUXMS"
  ]

  @@columns = \
  [
   "UCRSYTHHNY",
   "EXOFSCZQTB",
   "WGCKOGGMCU",
   "RZKFOPHNLR",
   "TUSMURQDAP",
   "RWBTNTGXTZ",
   "BRAYMIWZNU",
   "HYUSZDTBBX",
   "CECGIAUSCM",
   "DRUEMNVTES"
  ]

  @@diagonals = \
  [
   # diagonal2br
   "Y",
   "NB",
   "HTU",
   "HQCR",
   "TZMLP",
   "YCGNAZ",
   "SSGHDTU",
   "RFOPQXNX",
   "COKORGZBM",
   "UXCFUTWBCS", # main diagonal
   "EGKMNITSE",
   "WZSTMDUT",
   "RUBYZAV",
   "TWASIN",
   "RRUGM",
   "BYCE",
   "HEU",
   "CR",
   "D",
   # diagonal2bl
   "U",
   "EC",
   "WXR",
   "RGOS",
   "TZCFY",
   "RUKKST",
   "BWSFOCH",
   "HRBMOGZH",
   "CYATUPGQN",
   "DEUYNRHMTY",
   "RCSMTQNCB",
   "UGZIGDLU",
   "EIDWXAR",
   "MATZTP",
   "NUBNZ",
   "VSBU",
   "TCX",
   "EM",
   "S"
  ]

  @@diagonals2br = {
    0 => "UXCFUTWBCS",
    5 => "RRUGM",
    9 => "D",
    [0,0] => "UXCFUTWBCS", # same as 0
    [0,1] => "EGKMNITSE",
    [0,9] => "D",
    [1,0] => "COKORGZBM",
    [8,0] => "NB",
    [9,0] => "Y"
  }

  @@diagonals2bl = {
    0 => "U",
    2 => "WXR",
    9 => "DEUYNRHMTY",
    [0,2] => "WXR",
    [0,9] => "DEUYNRHMTY",
    [2,0] => "R", # behaviour undefined :)
    [7,9] => "TCX",
    [1,9] => "RCSMTQNCB",
    [9,9] => "S" # bottom right corner
  }

  ####################################################################

  def setup
    @vector = @@table_str.split
    @m = MatrixOverVector.new(@vector, 10, 10)
  end

  def test_new_with_two_args
    @m = MatrixOverVector.new(@vector, 10)
    assert_equal 10, @m.nrows
    assert_equal 10, @m.ncols
  end

  def test_new_with_three_args
    @m = MatrixOverVector.new(@vector, 10, 10)
    assert_equal 10, @m.nrows
    assert_equal 10, @m.ncols
  end

  def test_new_with_error
    assert_raise(RuntimeError) { MatrixOverVector.new("shilo", 2) }
    assert_raise(RuntimeError) do
      MatrixOverVector.new(@vector, 10, 9)
    end
  end

  ####################################################################

  def test_get_row
    @@rows.each_with_index do |row, idx|
      assert_equal row, @m.row(idx).join('') 
    end
    assert_nil @m.row(-1)
    assert_nil @m.row(10)
  end

  def test_get_column
    @@columns.each_with_index do |col, idx|
      assert_equal col.split(''), @m.column(idx)
    end
    assert_nil @m.column(-1)
    assert_nil @m.column(10)
  end

  def test_get_diagonal
    @@diagonals2br.each do |i, dgl|
      assert_equal dgl.split(''), @m.diagonal2br(i)
    end

    @@diagonals2bl.each do |i, dgl|
      assert_equal dgl.split(''), @m.diagonal2bl(i)
    end
  end

  ####################################################################

  def test_each_row
    rows = []
    @m.each_row do |row|
      rows << row.join('')
    end
    assert_equal @@rows, rows
  end

  def test_each_column
    cols = []
    @m.each_column do |col|
      cols << col.join('')
    end
    assert_equal @@columns, cols
  end

  def test_each_diagonal
    diagonals = []
    @m.each_diagonal do |dgl|
      diagonals << dgl.join('')
    end
    assert_equal @@diagonals.sort, diagonals.sort
  end

  ####################################################################

  def test_to_col
    assert_equal 1, @m.to_col([2,1])
    assert_equal 0, @m.to_col(0)
    assert_equal 9, @m.to_col(9)
    assert_equal 0, @m.to_col(10)
    assert_equal 9, @m.to_col(99)
  end
end
