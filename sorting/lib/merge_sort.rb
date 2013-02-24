

class MergeSort

  def sort(array)
    sort_rec(array, 0, array.length-1)
  end

  ####################################################################
  # sorts subarray between given points inclusive: [si,ei]
  #  si - start index
  #  ei - end index
  #
  # alternatively: extract subarray using slice or range selector in []
  
  private
  def sort_rec(arr, si, ei)

#    puts "sorting #{arr.inspect} between [#{si}, #{ei}]"

    # an array containing (n)one element is sorted 
    if si >= ei
      return arr[si,1]
    end

    # split in two equal parts
    # mi -- middle index
    mi1 = si + (ei-si)/2
    mi2 = si + (ei-si)/2 + 1

    # sort each subarray
    left  = sort_rec(arr, si, mi1)
    right = sort_rec(arr, mi2, ei)

    # merge sorted subarrays
    merge(left, right)
  end

  # la - left side array
  # ra - right side array
  def merge(la, ra)
#    puts "left: #{la.inspect}"
#    puts "rght: #{ra.inspect}"

    res = []

    # li - index in the left side array
    # ri - index in the right side array
    li = ri = 0

    while li < la.length && ri < ra.length
      if la[li] <= ra[ri]
        res << la[li]
        li += 1
      else
        res << ra[ri]
        ri += 1
      end
    end

    res + la[li..-1] + ra[ri..-1]
  end
end
