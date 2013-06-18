#!/usr/bin/env ruby

# # #
#
#

require 'optparse'
require 'corpus_counts'

@options = {
  :tag_unigrams => false,
  :tag_bigrams  => false,
  :tag_trigrams => false
}

OptionParser.new do |opts|
  opts.banner = "
  The original lettercase is preserved. Uppercase the input ahead, if you need it.
USAGE: #{File.basename($0)} [OPTIONS] tagged_corpus_file(s)
"

  opts.on('--[no-]tag-unigram-counts', 'collect tag unigrams (TAG-1-GRAM)') do |val|
    @options[:tag_unigrams] = val
  end

  opts.on('--[no-]tag-bigram-counts', 'collect tag bigrams (TAG-2-GRAM)') do |val|
    @options[:tag_bigrams] = val
  end

  opts.on('--[no-]tag-trigram-counts', 'collect tag trigrams (TAG-3-GRAM)') do |val|
    @options[:tag_trigrams] = val
  end

  opts.on('--[no-]tag-skipping-bigram-counts', 'collect tag bigrams (TAG-2-GRAM-GAP-1)') do |val|
    @options[:tag_bigrams] = val
  end

end.parse!

######################################################################

cc = CorpusCounts.new

lines = [
"Diese_DTFN Vorrichtung_NCFSN ist_VSPI3S deshalb_RD aufwendig_JP ._.",
"Oben_RP wird_VWPI3S Benzin_NCNSN auf_APPA die_ATDFA Wand_NCFSA aufgebracht_VLPP ._."
]

lines.each do |line|
  cc.learn_from_line line
end

cc.write
