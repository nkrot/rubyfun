#
# TODO
# Q: the class shares values of START and STOP with the external resource
#    how should they synchronize?
#

class Viterbi
  # stat files should also contain * and STOP symbols
  START = "*"
  STOP  = "STOP"

  attr_accessor :debug
  attr_writer :w_tags, :wt_prob, :ttt_prob

  def initialize
    @debug = false
    reset
  end

  def reset
    # pi(k,u,v) = value
    # position =>
    @pis = Hash.new {|h1,k1|
      # u =>
      h1[k1] = Hash.new {|h2,k2|
        # v => value
        h2[k2] = Hash.new {|h3,k3|
          h3[k3] = [0]
        }
      }
    }
    # PIs for two fake words that are inserted at the beginning of the sentence
    pi(0, START, START, 1)
    pi(1, START, START, 1)
  end

  def path
    @path.dup # make it immutable
  end
  alias tags path

  def process(words)
    reset

    @words = words.dup
    @words.unshift(START, START)
    @words.push(STOP, STOP)

    pis = Hash.new

    2.upto(@words.length-1) do |k|
      # ws - tags of the preprevious word
      # us - tags of the previous word
      # vs - tags of the current word
      ws = w_tags(@words[k-2])
      us = w_tags(@words[k-1])
      vs = w_tags(@words[k])

      say "\npreprev\t'#{@words[k-2]}'\t" + ws.inspect
      say "prev\t'#{@words[k-1]}'\t" + us.inspect
      say "curr\t'#{@words[k]}'\t"  + vs.inspect

      vs.each do |v|
        e = wt_prob(@words[k], v)
        say "e(x|v)=e(#{@words[k]},#{v})=#{e}"

        us.each do |u|
          pis.clear

          ws.each do |w|
            q = ttt_prob(w,u,v) # q(v|w,u)
            say "q(v|w,u)=q(#{v}|#{w},#{u})=#{q}"
            say "pi(k-1,w,u)=pi(#{k-1},#{w},#{u})=#{pi(k-1,w,u)}"
            pis[w] = pi(k-1,w,u) * q
          end

          # select best pi value
          say "Values of PI: " + pis.inspect
          best_w, best_pi = pis.max {|pi1, pi2| pi1[1] <=> pi2[1]}
          say "Best is for w=#{best_w} equals pi(k,u,v)=pi(#{k},#{u},#{v})=#{best_pi.inspect}"
          pi(k,u,v, best_pi*e, best_w)
        end
      end
    end

#    puts inspect

    restore_path(STOP, STOP)

    # remove special START and STOP symbols
    @path.shift(2)
    @path.pop(2)

    path
  end

  ####################################################################
  private
  ####################################################################

  def w_tags(word)
    @w_tags.call(word)
  end

  def wt_prob(word, tag)
    if word == STOP
      # e(STOP)=1
      # emission parameter e for the fake (last+1)th word is not used
      # in the formula. but the algorithm requires it for unification.
      # so, provide a value that will not change the overall result.
      1
    else
      @wt_prob.call(word, tag)
    end
  end

  def ttt_prob(pptag, ptag, tag)
    if ptag == STOP && tag == STOP
      # the 2nd STOP is unlikely to be in trigram resource
      1
    else
      @ttt_prob.call(pptag, ptag, tag)
    end
  end

  # k - position
  # u - tag of the previous word
  # v - tag of the current word
  # value
  # w - tag of the preprevious word
  def pi(k,u,v, value=nil, w=nil)
    if value
      @pis[k][u][v] = [value, w]
    end
    @pis[k][u][v][0] # return value
  end

  # return w -- tag of preprevious word in sequence (w,u,v)
  def bp(k,u,v)
    @pis[k][u][v][1]
  end

  def restore_path(u,v)
    @path = [v,u]
    @pis.keys.sort.reverse.each do |k|
#      puts "k=#{k}; pis=#{@pis[k].inspect}"
      w = bp(k,u,v)
#      puts "bp(k,u,v)=bp(#{k},#{u},#{v})=#{w}"
      break  unless w # TODO: sure that the start of the sentence was reached?
      @path << w
      u, v = w, u
    end
    @path.reverse!
  end

  def say(*msgs)
    if @debug
      msgs.each do |msg|
        puts msg
      end
    end
  end
end
