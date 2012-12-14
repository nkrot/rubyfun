#
# http://www.rubyquiz.com/quiz44.html
#
# TODO:
# 1. does not find the shortest path between words

class WordChains
  attr_accessor :verbose

  def initialize
    @verbose = false

    @dict = Hash.new {|h,k| h[k] = []}
    IO.foreach("/usr/share/dict/words") do |line|
      line.chomp!
      if line =~ /^[[:alpha:]]{4}$/
        add_to_dict(line.downcase)
      end
    end

#    @dict.each {|k,v| puts "#{k.inspect}=>#{v.inspect}"}

    @paths = Hash.new #{|h,k| h[k]=[]}
    @seen_items = {}
#    @level = 0
  end

  ####################################################################
  # startword, endword

  def process(sword, eword)
    reset

    verboser "\nFinding steps from '#{sword}' to '#{eword}'"

    eword = eword.to_sym
    stack = [sword.to_sym]
    chain = []

    add_path("_", sword)

    while !stack.empty?
      sword = stack.shift

      if sword == eword
        chain = restore_path(sword)
        break
      end

      each_mask(sword) do |mask|
#        verboser @seen_items.inspect

        if already_visited?(mask)
          verboser "Skipping: #{mask}"
          next
        end

        mark_as_visited(mask)
        mark_as_visited(sword)

        each_word_by_mask(mask) do |word|
          unless already_visited?(word)
#            mark_as_visited(word)
            stack.unshift word
            add_path(sword, word)
          end
        end
      end
    end

    return chain 
  end

  ####################################################################

  private

  def reset
    @paths.clear
    @seen_items.clear
  end

  ####################################################################

  def add_to_dict(word)
    _word = word.to_sym
    each_mask(word) {|mask|
      unless @dict[mask].include?(_word)
        @dict[mask] << _word
      end
    }
  end

  ####################################################################

  def add_path(src, trg)
    if @paths.key?(trg)
      raise "Oh, no this should not have happened: '#{src}' instead of '#{@paths[trg]}'?"
    end
    @paths[trg] = src
  end

  ####################################################################

  def restore_path(trg)
    path = []
    while @paths.key?(trg)
      path << trg.to_s
      trg = @paths[trg]
    end
    path << trg.to_s
    path.reverse
  end

  ####################################################################

  # recursive implementation sucks: Stack level too deep
#  def process(sword, eword)
#    @level += 1
#    verboser "\n[#{@level}] Finding steps from '#{sword}' to '#{eword}'"
#
#    if sword == eword
#      puts "Found!"
#      return sword
#    end
#
#    each_mask(sword) do |mask|
##      verboser @seen_items.inspect
#
#      if already_visited?(mask)
#        verboser "Skipping: #{mask}"
#        next
#      end
#
#      mark_as_visited(mask)
#
#      each_word_by_mask(mask) do |word|
#        unless already_visited?(word)
#          mark_as_visited(word)
#          process(word, eword)
#        end
#      end
#    end
#    @level -= 1
#  end

  ####################################################################

  def already_visited?(item)
    @seen_items.include?(item) || @paths.key?(item)
  end

  def mark_as_visited(val)
    @seen_items[val] = nil
  end

  ####################################################################

  def each_word_by_mask(mask)
    mask = mask.to_sym
    if @dict.key?(mask)
      verboser "#{mask}: " + @dict[mask].inspect

      @dict[mask].each do |word|
        yield word
      end
    end
  end

  ####################################################################

  def each_mask(word)
    word = word.to_s
    0.upto(word.length-1) do |i|
      _word = word.dup
      _word[i,1] = "_"
      yield _word.to_sym
    end
  end

  ####################################################################

  def verboser(msg)
    if @verbose
      puts msg
    end
  end
end

######################################################################

if __FILE__ == $0
  wch = WordChains.new
  wch.verbose = true
#  chain = wch.process("rrrr", "ruby") #=> []
  chain = wch.process("duck", "ruby")
  puts chain.inspect
#  wch.process("rube", "ruby")
end
