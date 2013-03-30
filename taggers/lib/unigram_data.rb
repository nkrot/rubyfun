
class UnigramData
  # pseudo word, replaces any rare word
  # TODO: duplicated in morphotype.rb
  RARE = "_RARE_"
  # special symbols for the start and end of the sentence
  # TODO: actually, do not occur in unigram data, but only
  # in trigram data
  START = "*"
  STOP  = "STOP"

  attr_writer :morphotype

  def initialize

    # @wt_counts = {
    #   word1 => {
    #     tag1 => count1,
    #     tag2 => count2
    #   },
    #   word2 => {
    #     tag1 => count1,
    #   }
    # }
    @wt_counts = Hash.new {|h,k|
      h[k] = Hash.new {|h2,k2| h2[k2] = 0}
    }

    # tag counts:
    # @t_counts = {
    #   tag1 => count1,
    #   tag2 => count2,
    # }
    @t_counts = Hash.new {|h,k| h[k] = 0}

    @tagset = []
    @unigram_probs = {}

    # converter to _RARE_ or one of other classes
    @morphotype = nil
  end

  def load_counts_from_file(fname)
    IO.foreach(fname) { |line|
      line.chomp!
      if line =~ /WORDTAG/
        count, _, tag, word = line.split
        count = count.to_i
        @wt_counts[word][tag] += count
        @t_counts[tag] += count
        @tagset << tag  unless @tagset.include?(tag)
      end
    }
    compute_probabilities
  end

  def morphotype
    # start on request
    @morphotype ||= Morphotype.new
  end

  # returns a hash with tags (in keys) and probabilites (in values)
  #  { tag1 => prob1, tag2 => prob2 }
  def probs_of(word)
    @unigram_probs[word]
  end

  def prob_of(word, tag)
#    puts "prob_of(#{word}, #{tag})"
    if @unigram_probs[word]
      @unigram_probs[word][tag]
    else
      prob_of(morphotype.type_of_rare(word), tag)
    end
  end

  alias prob_with_tag prob_of

  def tags_of(word)
    if word == START || word == STOP
      [word]
    elsif @unigram_probs.key?(word)
      @unigram_probs[word].keys
    end
  end

  def default_probs
    @unigram_probs[RARE]
  end

  def default_prob_with_tag(tag)
    @unigram_probs[RARE][tag]
  end

  def best_tag(word)
    best_tag_with_prob(word).first
  end

  def best_tag_with_prob(word)
    probs = probs_of(word) || default_probs
    probs.max {|t1, t2| t1[1] <=> t2[1]}
  end

  def all_tags
    @tagset.dup
  end

  def dump
    @unigram_probs.each do |word, tagdata|
      tagdata.each do |tag, prob|
        puts "e(word|tag)=e(#{word}|#{tag})=#{prob}"
      end
    end
  end

  ####################################################################
  private
  ####################################################################

  def compute_probabilities
    @wt_counts.each do |word, wt_counts|
      wt_counts.each do |tag, wt_count|
        e = wt_count.to_f / @t_counts[tag].to_f
#        puts "#{word}/#{tag} #{wt_count} e=#{e}"
        @unigram_probs[word] ||= Hash.new
        @unigram_probs[word][tag] = e
      end
    end
  end
end

if __FILE__ == $0
  # USAGE: unigram_data.rb gene.train.rare.counts
  unigrams = UnigramData.new
  unigrams.load_counts_from_file ARGV[0]

  unigrams.dump
end
