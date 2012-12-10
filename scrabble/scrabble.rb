#!/usr/bin/env ruby

# # #
# USAGE: scrabble.rb ruby words.txt
# bur
# bury
# buy
# rub

def count_letters(word)
#  counts = Hash.new{|h,k| h[k] = 0}
  counts = {}
  word.downcase.each_char {|ch|
    counts[ch] ||= 0
    counts[ch] += 1
  }
  return counts
end

query = ARGV.shift

query_letters = count_letters(query)

#puts letters.inspect

while word = gets
  word.chomp!

  # skip garbage
  # skip words longer than the query can not be constructed from the query
  if word.length < 3 || word.length > query.length || word.downcase == query.downcase
    next
  end

  word_letters = count_letters(word)
  
  found = true
  word_letters.each do |ch, count|
    unless query_letters.key?(ch) && word_letters[ch] <= query_letters[ch]
#    unless word_letters[ch] <= query_letters[ch] # works if Hash.new {|h,k| h[k] = 0}
      found = false
      break
    end
  end

  if found
    puts word
  end
end
