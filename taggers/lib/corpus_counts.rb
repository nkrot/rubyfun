
class CorpusCounts
  START = "@START@"
  STOP  = "@STOP@"

  attr_accessor :tag_unigram_counts
  attr_accessor :tag_bigram_counts
  attr_accessor :tag_trigram_counts
  attr_accessor :word_tag_unigram_counts
  attr_accessor :tag_skip1_bigram_counts
  attr_accessor :labels

  def initialize
    @tag_unigram_counts      = new_hash

    @tag_bigram_counts       = new_hash
    @tag_skip1_bigram_counts = new_hash

    @tag_trigram_counts      = new_hash

    @word_tag_unigram_counts = new_hash

    @labels = {
      # symbols on the left must correspond to hash names with counts
      :tag_unigram_counts => "TAG-1-GRAM",
      :tag_bigram_counts  => "TAG-2-GRAM",
      :tag_trigram_counts => "TAG-3-GRAM",
      :tag_skip1_bigram_counts => "TAG-1-GRAM-GAP-1",
      :word_tag_unigram_counts => "WORD-TAG-1-GRAM"
    }
  end

  def new_hash
    Hash.new {|h,k| h[k] = 0}
  end

  def learn_from_file(*fnames)
    fnames = fnames.flatten

    check_files_exist fnames

    fnames.each do |fname|
      IO.foreach do |line|
        line.chomp!
        unless line.empty? || line =~ /^#/
          learn_from_line line
        end
      end
    end
  end

  ##################################################################
  # expected input: one tagged sentence per line
  # ex: I_PP1SN love_VB apples_NNS ._.

  def learn_from_line line
    tokens = tokenize(line)

    count_tag_unigrams      @tag_unigram_counts, tokens
    count_word_tag_unigrams @word_tag_unigram_counts, tokens

    count_tag_bigrams       @tag_bigram_counts,  tokens
    count_tag_trigrams      @tag_trigram_counts, tokens

    count_tag_bigrams       @tag_skip1_bigram_counts, tokens, gap=1
  end

  def learn_from_lines lines
    lines.each {|line| learn_from_line line}
  end

  ##################################################################

  def count_tag_unigrams counts, wts
    wts = tokenize(wts)
    wts.each {|w,t| counts[t] += 1}
    counts
  end

  ##################################################################

  def count_word_tag_unigrams counts, wts
    wts = tokenize(wts)
    wts.each {|w,t| counts["#{w} #{t}"] += 1}
    counts
  end

  ##################################################################

  def count_tag_bigrams counts, wts, gap=0
    wts = tokenize(wts)
    # extract tags only
    tags = wts.map {|w,t| t}

    # add fake start/end tags
    tags.unshift(START).push(STOP)
    # TODO: shouldn't it be different artificial tokens?
    gap.times { tags.unshift(START) }

#    puts tags.inspect
    # collect bigrams or gappy bigrams
    (1+gap).upto(tags.length-1) do |i|
      bigram = tags[i-1-gap] + " " + tags[i]
      counts[bigram] += 1
    end
    counts
  end

  ##################################################################

  def count_tag_trigrams counts, wts
    wts = tokenize(wts)
    # extract tags only
    tags = wts.map {|w,t| t}
    # add fake start/end tags
    tags.unshift(START, START).push(STOP)
#    puts tags.inspect
    # collect trigrams
    2.upto(tags.length-1) do |i|
      trigram = tags[i-2,3].join(' ')
      counts[trigram] += 1
    end
    counts
  end

  ##################################################################

  # https://practicingruby.com/articles/shared/rvdcaomuyjzr
  def write(out=nil)
    to_be_closed = false
    case 
    when out.nil?
      out = STDOUT
    when out.is_a?(String)
      out = File.new(out, "w+")
      to_be_closed = true
    when out.respond_to?(:write)
      # ok
    else
      raise "Invalid object #{out.class}, should be able to respond to :write"
    end

    @labels.each do |_hash, label|
      hash = send(_hash)
      unless hash.empty?
        # this expands to lines like:
        # write_hash @tag_unigram_counts,      "TAG-1-GRAM",       out
        # write_hash @tag_bigram_counts,       "TAG-2-GRAM",       out
        write_hash hash, label, out
      end
    end

    out.close  if to_be_closed
  end

  ##################################################################
  private
  ##################################################################

  def write_hash(hash, label, channel=STDOUT)
    unless hash.empty?
      hash.each do |key, val|
        channel.puts "#{label}\t#{key}\t#{val}"
      end
    end
  end

  # in: "Ancient_JJ maya_NNS died_VBD ._."
  # out: [["Ancient", "JJ"], ["maya", "NNS"], ["died", "VBD"], [".", "."]]
  def tokenize tagged_sentence
    case
    when tagged_sentence.is_a?(WordTagArray)
      tagged_sentence
    when tagged_sentence.is_a?(Array)
#      tagged_sentence.map {|ts| tokenize(ts) }
      raise "Can not run for an Array of sentences"
    else
      wts = tagged_sentence.scan(/([^\s]+)_([^_\s]+)/)
      WordTagArray.new(wts) # TODO: this creates a copy of the original array
    end
  end

  def check_files_exist(fnames)
    fnames.each do |fname|
      unless File.exist? fname
        raise "File '#{fname}' not found. Aborting"
      end
    end
  end

  class WordTagArray < Array
  end
end
