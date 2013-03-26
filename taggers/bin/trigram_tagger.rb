#!/usr/bin/ruby

# # #
#
#

require 'optparse'
require 'unigram_data'
require 'trigram_data'
require 'morphotype'
require 'viterbi'

@options = {
  :verbose => false,
  :mode => :single
}

OptionParser.new do |opts|
  opts.banner = "
  HMM trigram tagger with Viterbi algorithm
USAGE: #{File.basename($0)} [OPTIONS] gene.train.rare.counts gene.test
OPTIONS:
"
  opts.on('--types-of-rare',
          'classify into several classes (instead of just one _RARE_ class).',
          'It is assumed that the file with counts contains all necessary', 
          'data for all possible classes') do
    @options[:mode] = :multi
  end

  opts.on('-d', '--debug', 'print overwhelming amount of info') do
    @options[:verbose] = true
  end

  opts.separator " "
end.parse!

file_with_counts = ARGV.shift

unigrams = UnigramData.new
unigrams.load_counts_from_file file_with_counts
unigrams.morphotype = Morphotype.new(@options[:mode])

trigrams = TrigramData.new
# loading counts from file and computing them from corpus gives different values
trigrams.load_counts_from_file file_with_counts
#trigrams.learn_from_corpus file_with_counts # ex: gene.train.rare

######################################################################

def each_sentence
  ARGF.each("") do |paragraph|
    words = paragraph.split("\n").map {|line| line.chomp}
    yield words
  end
end

######################################################################

vit = Viterbi.new

vit.w_tags = lambda {|word|
  # TODO: with many morphological classes, should the tags
  # be looked up for a every morphological class (ALLCAPS, NUMERIC),
  # instead of assigning *all* possible tags?
  # For example, verbs can not have numbers, therefore can not be NUMERIC
  unigrams.tags_of(word) || unigrams.all_tags
}

vit.wt_prob = lambda {|word,tag|
  # look up word or its class (_RARE_, _NUMERIC_, _ALLCAPS_, etc)
  unigrams.prob_of(word, tag)
}

vit.ttt_prob = lambda {|pptag, ptag, tag|
  trigrams.prob_of(pptag, ptag, tag) # q(tag|pptag,ptag)
}

each_sentence do |words|
  vit.process(words)

  words.zip(vit.tags).each {|arr|
    puts arr.join(" ")
  }

  puts ""
end

