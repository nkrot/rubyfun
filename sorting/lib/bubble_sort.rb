#
#
#

class BubbleSort

  attr_accessor :sorts_before, :sorts_after

  def initialize
    @sorts_before = Proc.new{|a,b| a < b}
    @sorts_after  = Proc.new{|a,b| a > b}
  end

  def sort(data)
    sort_asc data
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
    
    last = res.length-1
    0.upto(last) do |i|
      0.upto(last) do |j|
        if comparer.call(res[i], res[j])
          res[i], res[j] = res[j], res[i]
        end
      end
    end

    res
  end

#  def sorts_before?(a,b)
#    a < b
#  end
end

