
class CorpusCounts

  attr_accessor :tag_unigram_counts

  def initialize
    @tag_unigram_counts = Hash.new {|h,k| h[k] = 0}
    @word_tag_unigram_counts = Hash.new {|h,k| h[k] = 0}
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

  # expected input: one tagged sentence per line
  # ex: I_PP1SN love_VB apples_NNS ._.
  def learn_from_line(line)
    tokens = tokenize(line)

    count_tag_unigrams tokens
    count_word_tag_unigrams tokens

    # add fake START and STOP words for bigrams
    count_tag_bigrams tokens

    count_tag_trigrams tokens

    count_tag_bigrams tokens, gap=1
  end

  def count_tag_unigrams wts
    wts = tokenize(wts)
    wts.each {|w,t| @tag_unigram_counts[t] += 1}
  end

  def count_word_tag_unigrams wts
    wts = tokenize(wts)
    wts.each {|w,t| @tag_unigram_counts["#{w} #{t}"] += 1}
  end

  def count_tag_bigrams wts, gap=0
  end

  def count_tag_trigrams wts
  end

  def write
    # dump all to a single file
    raise "Not yet implemented"
  end

  ##################################################################
  private
  ##################################################################

  # in: "Ancient_JJ maya_NNS died_VBD ._."
  # out: [["Ancient", "JJ"], ["maya", "NNS"], ["died", "VBD"], [".", "."]]
  def tokenize tagged_sentence
    if tagged_sentence.is_a? Array
      tagged_sentence
    else
#    tokens = tagged_sentence.split.map {|tw| get_word_and_tag(tw)}
      tagged_sentence.scan(/([^\s]+)_([^_\s]+)/)
    end
  end

#  def get_word_and_tag tw
#    tw.scan(/(.+)_([^_]+)$/)
#  end

  def check_files_exist(fnames)
    fnames.each do |fname|
      unless File.exist? fname
        raise "File '#{fname}' not found. Aborting"
      end
    end
  end
end
