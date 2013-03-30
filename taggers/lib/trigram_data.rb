
class TrigramData
  STOP = "STOP"

  def initialize
    @tag_bigrams = Hash.new {|h,k| h[k] = 0}
    @tag_trigrams = Hash.new {|h,k| h[k] = 0}
    @trigram_probs = {}
    @tagset = []
  end

#  def trigrams
#  end

  ####################################################################
  # 4 WORDTAG I-GENE disease
  # 41072 1-GRAM I-GENE
  # 24435 2-GRAM I-GENE I-GENE
  # 749 3-GRAM * * I-GENE
  # 1 3-GRAM O I-GENE STOP

  def load_counts_from_file(fname)
    IO.foreach(fname) {|line|
      line.chomp!
      count, label, *tags = line.split
      count = count.to_i
      case label
      when "2-GRAM"
        @tag_bigrams[tags] = count
      when "3-GRAM"
        @tag_trigrams[tags] = count
      end
    }
    compute_probabilities
  end

  # ppt - preprevious tag
  # pt  - previous tag
  # ct  - current tag
  # the order of arguments does not correspond to the math expression
  #  q(ct|ppt,pt) -- current tag conditioned on two previous 
  def prob_of(ppt,pt,ct)
    @trigram_probs[[ppt,pt,ct]]
  end

  def dump
    @trigram_probs.each do |(pptag,ptag,tag), prob|
      puts "q(tag|pptag,ptag)=q(#{tag}|#{pptag},#{ptag})=#{prob}"
    end
  end

  ####################################################################
  # read tagged corpus and collect tag counts

  def learn_from_corpus(*fnames)
    fnames = fnames.flatten

    # array of words in the current sentence
    # at each moment it should hold exactly 3 tokens
    @sent_tags = []
    reset

    fnames.each do |fname|
      if File.exist? fname
        learn_from_file fname
      else
        raise "File not found: #{fname}"
      end
    end

    compute_probabilities
  end

  ####################################################################
  private
  ####################################################################

  def learn_from_file(fname)
    eos = true # end of sentence.

    IO.foreach(fname) { |line|
      line.chomp!

      #  puts "LINE: #{line}"
      if line.empty?
        eos = true
      end

      if eos
        # finish the previous sentence
        add_tag(STOP)
        # start the new sentence
        eos = false
        reset
      else
        word, tag = line.split
        add_tag(tag)
      end
    }

    # finish the previous sentence
    # because there is no newline after the last word
    add_tag(STOP)
  end

  def add_tag(tag)
    @sent_tags.shift
    @tag_bigrams[@sent_tags.dup] += 1

    @sent_tags << tag
    @tag_trigrams[@sent_tags.dup] += 1

#    unless tag == STOP || @tagset.include?(tag)
#      @tagset << tag
#    end

#    puts "TAGS: #{@sent_tags.inspect}"
  end

  def reset
    @sent_tags.clear
#    @sent_tags += ["*", "*", "*"] # fuck! the result is another object in ruby 1.9
    @sent_tags << "*" << "*" << "*"
  end

#  def bigram(arr=@sent_tags)
#    arr[0,2].join(';')
#  end

#  def trigram
#    @sent_tags[0,3].join(';')
#  end

  # extract bigram tag sequence from trigram tag sequence
  def t2b(tseq)
#    if tseq.is_a? Array
      tseq[0,2]
#    else
#      # this supports learn_from_corpus. TODO: get rid of it
#      bigram(tseq.split(";"))
#    end
  end

  # for each trigram compute its probability in accordance with the formula
  #  q(t3|t1,t2) = count(t1,t2,t3) / count(t1,t2)
  def compute_probabilities
    @tag_trigrams.each do |tritags, count|
      @trigram_probs [tritags] = count.to_f / @tag_bigrams[t2b(tritags)].to_f
    end
  end
end

if __FILE__ == $0
  # USAGE: trigram_data.rb gene.train.rare.counts
  trigrams = TrigramData.new
  trigrams.load_counts_from_file ARGV[0]

  trigrams.dump
end
