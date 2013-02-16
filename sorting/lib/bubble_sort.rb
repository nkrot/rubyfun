#
#
#

class BubbleSort

  def sort(arr)
    res = arr.dup
    
    last = res.length-1
    0.upto(last) do |i|
      0.upto(last) do |j|
        if res[i] < res[j]
          res[i], res[j] = res[j], res[i]
        end
      end
    end

    res
  end
end

# HW:
# cocktail sort is an improved version of bubble sort
