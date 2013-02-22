
class CocktailSort

  # sort in increasing order, in place
  def sort(arr)
    verbose = false

    # l and r are the left and right boundaries of the working range
    l = 0
    r = arr.length-1
    _c = 0 # number of comparisons

    if verbose
      explain arr, l, r, \
      "initial state (l=#{l} r=#{r} comparisons=#{_c})"
    end

    changed = true
    while changed  # l < r will not work
      changed = false

      #
      # left-to-right pass
      #
      l.upto(r-1) do |i|
        _c += 1
        if arr[i] > arr[i+1]
          arr[i], arr[i+1] = arr[i+1], arr[i]
          r = i
          changed = true
        end
      end

      # doing r-1 here is worse then r=i above
#      r=-1

      if verbose
        explain arr, l, r, \
        "\nAfter left-to-right pass (l=#{l} r=#{r} comparisons=#{_c}):"
      end

      break  unless changed

      #
      # right-to-left pass
      #
      r.downto(l+1) do |i|
        _c += 1
        if arr[i-1] > arr[i]
          arr[i], arr[i-1] = arr[i-1], arr[i]
          l = i
          changed = true
        end
      end

      # doing l-1 here is worse then l=i above
#      l=-1

      if verbose
        explain arr, l, r, \
        "After right-to-left pass (l=#{l} r=#{r} comparisons=#{_c}):"
      end
    end

    arr
  end

  ####################################################################

  private
  def explain(arr, l, r, msg=nil)
    data = (l == 0 ? [] : arr[0..l-1]).inspect
    data << " " << arr[l..r].inspect
    data << " " << (r == arr.length-1 ? [] : arr[r+1..-1]).inspect
    
    puts msg  if msg
    puts "[0..l) [l..r] (l..end]: " + data
  end

end
