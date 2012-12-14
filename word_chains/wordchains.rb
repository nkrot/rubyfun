
# http://www.rubyquiz.com/quiz44.html
#

class WordChains
  attr_accessor :verbose

  def initialize
    @verbose = false

    @dict = Hash.new {|h,k| h[k] = []}
#    File.readlines("words.4").each do |word|
#      add_to_dict(word.chomp)
#    end
    IO.foreach("/usr/share/dict/words") do |line|
      line.chomp!
      if line.length == 4
        add_to_dict(line.downcase)
      end
    end

#    @dict.each {|k,v| puts "#{k.inspect}=>#{v.inspect}"}

    @seen_items = {}
    @level = 0
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
  # startword, endword

  def process(sword, eword)
    verboser "\nFinding steps from '#{sword}' to '#{eword}'"

    eword = eword.to_sym
    stack = [sword.to_sym]

    while !stack.empty?
      sword = stack.shift

      if sword == eword
        puts "Found!"
        return sword
      end

      each_mask(sword) do |mask|
#        verboser @seen_items.inspect

        if already_visited?(mask)
          verboser "Skipping: #{mask}"
          next
        end

        mark_as_visited(mask)

        each_word_by_mask(mask) do |word|
          unless already_visited?(word)
            mark_as_visited(word)
            stack.unshift word
          end
        end
      end
    end
  end

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

  def already_visited?(mask)
    @seen_items.include?(mask)
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
  puts wch.process("duck", "ruby")
#  wch.process("rube", "ruby")
end
