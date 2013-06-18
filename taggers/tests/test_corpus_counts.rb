#!/usr/bin/env ruby

# # #
# http://www.rubyinside.com/a-minitestspec-tutorial-elegant-spec-style-testing-that-comes-with-ruby-5354.html
#

require 'minitest/spec'
require 'minitest/autorun'

require 'corpus_counts'

describe CorpusCounts do
  before do
    @tagged_sentences = [
         "Ancient_JJ maya_NNS kept_VBD time_NN with_IN a_AT kind_NN of_IN solar_JJ calendar_NN ._."
    ]
    @cc = CorpusCounts.new
    @counts = @cc.new_hash
  end

  it "can learn tag unigrams from a line" do
    sent = @tagged_sentences.first
    @cc.count_tag_unigrams @counts, sent

    @counts["NN"].must_equal 3
    @counts["NOTAG"].must_equal 0
  end

  it "can learn word-tag unigrams from a line" do
    sent = @tagged_sentences.first
    @cc.count_word_tag_unigrams @counts, sent

    @counts["time NN"].must_equal 1
    @counts["time VB"].must_equal 0
  end

  it "can learn tag bigrams from a line" do
    sent = @tagged_sentences.first
    @cc.count_tag_bigrams @counts, sent

    @counts["#{CorpusCounts::START} JJ"].must_equal 1
    @counts["NN IN"].must_equal 2
    @counts["JJ VBD"].must_equal 0
  end  

  it "can learn gappy tag bigrams from a line" do
    sent = @tagged_sentences.first
    @cc.count_tag_bigrams @counts, sent, gap=1

    @counts["NN IN"].must_equal 0
    @counts["JJ VBD"].must_equal 1
  end  

  it "can learn tag trigrams from a line" do
    sent = @tagged_sentences.first
    @cc.count_tag_trigrams @counts, sent

    @counts["JJ NNS VBD"].must_equal 1
    @counts["JJ NN ."].must_equal 1
    @counts.length.must_equal 12
  end  

  it "can learn unigrams from a text" #oops

end

