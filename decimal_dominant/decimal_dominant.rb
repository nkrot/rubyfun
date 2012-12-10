#
# DecimalDominant --
#   algorithm for finding decimal dominant in an array.
#
#   A decimal dominant is an element in the array of length N that occurs
#   more than N/10 times.
#   The array is not sorted. 
#
# Algorithm:
#

class DecimalDominant

  attr_accessor :debug

  def run(items)

    buckets = [] # store items (in the value)
    counts  = Array.new(9, 0) # store item counts

    # O(n) to find decimal dominant *candidates*
    items.each do |item|
      verboser "New item is #{item}"

      i = buckets.index(item)

      if i
        verboser "..already in the bucket ##{i}. add it there"
        counts[i] += 1
      else
        verboser "..is an unknown item"
        j = counts.index(0)

        if j
          # if there is an empty bucket, place the item in it
          verboser "....place this item into the bucket ##{j}."
          buckets[j] = item
          counts[j] = 1
        else
          # otherwise, substract 1 from each counter
          verboser "....remove one item from all buckets"
          counts.collect! {|c| c -= 1 }
        end
        
        if @debug
          puts "buckets/counts: " + buckets.zip(counts).collect {|arr| arr.join("=")}.inspect
        end
      end
    end

    result = []
    c_dd = items.length / 10

    counts.each_with_index do |c, i|
      item = buckets[i]
      # just selecting items that have a count > 1 in the bucket
      # is not enough to deciding that the value is a dominant.
      # Proof:
      #  if a value repeats several (but less than required to be
      #  a dominant) times at the end of the array, it was not
      #  canceled by a new different value and its count is now
      #  more than 1.
      if c > 1
        c_item = items.select {|_item| _item == item}.length
        result << item  if c_item > c_dd
      end
    end

    return result
  end

  ####################################################################
  # another (brute force) algorithm

  def run_bf(items)

    counts = Hash.new{|h,k| h[k] = 0}

    items.each {|item| counts[item] += 1 }
    
    dd = items.length / 10
    
    results = []
    counts.each {|item, count|
      results << item   if count > dd
    }
    
    return results
  end

  ####################################################################

  def verboser(msg)
    if @debug
      puts msg
    end
  end
end
