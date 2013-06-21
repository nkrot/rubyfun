#!/usr/bin/env ruby

# # #
# http://www.rubyinside.com/a-minitestspec-tutorial-elegant-spec-style-testing-that-comes-with-ruby-5354.html
#

require 'minitest/spec'
require 'minitest/autorun'
require 'tempfile'

require 'corpus_counts'

describe CorpusCounts do
  before do
    @tagged_sentences = [
         "Ancient_JJ maya_NNS kept_VBD time_NN with_IN a_AT kind_NN of_IN solar_JJ calendar_NN ._.",
         "Ancient_JJ maya_NNS died_VBD away_RP ._."
    ]
    @cc = CorpusCounts.new
    @counts = @cc.new_hash
  end

  it "can learn tag unigrams from a line" do
    sent = @tagged_sentences.first
    @cc.count_tag_unigrams @counts, sent

    @counts.length.must_equal 7
    @counts["NN"].must_equal 3
    @counts["NOTAG"].must_equal 0
  end

  it "can learn word-tag unigrams from a line" do
    sent = @tagged_sentences.first
    @cc.count_word_tag_unigrams @counts, sent

    @counts.length.must_equal 11
    @counts["time NN"].must_equal 1
    @counts["time VB"].must_equal 0
  end

  it "can learn tag bigrams from a line" do
    sent = @tagged_sentences.first
    @cc.count_tag_bigrams @counts, sent

    @counts.length.must_equal 11
    @counts["#{CorpusCounts::START} JJ"].must_equal 1
    @counts["NN IN"].must_equal 2
    @counts["JJ VBD"].must_equal 0
    @counts["#{CorpusCounts::STOP} #{CorpusCounts::START}"].must_equal 0 # had bug on this
  end  

  it "can learn 1-gappy tag bigrams from a line" do
    sent = @tagged_sentences.first
    @cc.count_tag_bigrams @counts, sent, gap=1

    @counts.length.must_equal 11
    @counts["#{CorpusCounts::START} JJ"].must_equal 1
    @counts["#{CorpusCounts::START} NNS"].must_equal 1
    @counts["NN IN"].must_equal 0
    @counts["JJ VBD"].must_equal 1
    @counts["IN NN"].must_equal 2
  end  

  it "can learn tag trigrams from a line" do
    sent = @tagged_sentences.first
    @cc.count_tag_trigrams @counts, sent

    @counts.length.must_equal 12
    @counts["JJ NNS VBD"].must_equal 1
    @counts["JJ NN ."].must_equal 1
    @counts["#{CorpusCounts::START} #{CorpusCounts::START} JJ"].must_equal 1
    @counts["NN . #{CorpusCounts::STOP}"].must_equal 1
  end  

  it "can learn all from a line" do
    sent = @tagged_sentences.first
    @cc.learn_from_line sent

    @cc.tag_unigram_counts.length.must_equal 7
    @cc.word_tag_unigram_counts.length.must_equal 11
    @cc.tag_bigram_counts.length.must_equal 11
    @cc.tag_skip1_bigram_counts.length.must_equal 11
    @cc.tag_trigram_counts.length.must_equal 12
  end

  it "can not yet learn bits from a text" do
    proc {
      @cc.count_tag_unigrams(@counts, @tagged_sentences) 
    }.must_raise(RuntimeError)
#    puts @counts.inspect

    proc {
      @cc.count_word_tag_unigrams @counts, @tagged_sentences
    }.must_raise(RuntimeError)

    proc {
      @cc.count_tag_bigrams @counts, @tagged_sentences
    }.must_raise(RuntimeError)

    proc {
      @cc.count_tag_bigrams @counts, @tagged_sentences, gap=1
    }.must_raise(RuntimeError)

    proc {
      @cc.count_tag_trigrams @counts, @tagged_sentences
    }.must_raise(RuntimeError)
  end

  it "can learn all counts from a text at once" do
    @cc.learn_from_lines @tagged_sentences

    @cc.tag_unigram_counts.length.must_equal 8
    @cc.word_tag_unigram_counts.length.must_equal 13
    @cc.tag_bigram_counts.length.must_equal 13
    @cc.tag_skip1_bigram_counts.length.must_equal 14
    @cc.tag_trigram_counts.length.must_equal 15


    @cc.tag_bigram_counts["JJ NNS"].must_equal 2
    @cc.tag_bigram_counts["RP ."].must_equal 1
    @cc.tag_bigram_counts[". #{CorpusCounts::STOP}"].must_equal 2
  end

  it "can write all counts to a file" do
    @cc.learn_from_lines @tagged_sentences
    outfile = Tempfile.new("tmp.test_corpus_counts.rb")
    outfile.unlink
    begin
      @cc.write outfile
      outfile.rewind
      lines = outfile.readlines
      lines.grep(/GAP-1/).must_include "TAG-1-GRAM-GAP-1\t@START@ JJ\t2\n"
      lines.grep(/TAG-3-GRAM/).must_include "TAG-3-GRAM\tRP . @STOP@\t1\n"
      lines.grep(/WORD-TAG-1-GRAM/).must_include "WORD-TAG-1-GRAM\tmaya NNS\t2\n"
    ensure
      outfile.close!
    end
  end

end

