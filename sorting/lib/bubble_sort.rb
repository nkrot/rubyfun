#
#
#

class BubbleSort

  attr_accessor :sorts_before, :sorts_after

  def initialize
    @sorts_before = Proc.new{|a,b| a <= b}
    @sorts_after  = Proc.new{|a,b| a >= b}
  end

#  def sort(data, &blk = @sorts_before) # setting default here is not allowed
  def sort(data, &blk)
    unless block_given?
      blk = @sorts_before
    end
    sort_bs(data, blk)
  end

  def sort_asc(data)
    sort_bs data, @sorts_before
  end

  def sort_desc(data)
    sort_bs data, @sorts_after
  end

  ####################################################################

  private
  def sort_bs(arr, comparer)
    res = arr.dup

    _c = 0 # number of comparisons
    last = res.length-1

    explain "Initial: #{res.inspect}"

    last.times do
      1.upto(last) do |i|
        _c += 1
        unless comparer.call(res[i-1], res[i])
          res[i-1], res[i] = res[i], res[i-1]
          explain "Swapped #{res[i]} <-> #{res[i-1]}: #{res.inspect}"
        end
      end
    end

    explain "Number of comparisons: #{_c}"
    res
  end

  # if you want to get rid of sort => sort_bs wrapping:
##  def sort(arr, &comparer)
##    res = arr.dup
##
##    unless block_given?
##      comparer = @sorts_before
##    end
##
##    # ...
##    unless comparer.call(res[i-1], res[i])
##      ...
##    end
##    #...
##  end


#  def sorts_before?(a,b)
#    a < b
#  end

  def explain msg
    if false
      puts msg
    end
  end
end

######################################################################
######################################################################
######################################################################

class BubbleSort2

  def sort(arr)
    res = arr.dup
    
    _c = 0 # number of comparisons
    last = res.length-1

    explain "Initial: #{res.inspect}"

    last.times do
      1.upto(last) do |i|
        _c += 1

        # ugly!
        if block_given?
          ordered = yield(res[i-1], res[i])
        else
          ordered = res[i-1] < res[i]
        end

        unless ordered
          res[i-1], res[i] = res[i], res[i-1]
          explain "Swapped #{res[i]} <-> #{res[i-1]}: #{res.inspect}"
        end
      end
    end

    explain "Number of comparisons: #{_c}"
    res
  end

  def explain msg
    if false
      puts msg
    end
  end
end

######################################################################
