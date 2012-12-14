#!/usr/bin/ruby

require 'test/unit'
require 'wordchains.rb'

class TestWordChains < Test::Unit::TestCase

  @@tests = [
             %w{duck dusk rusk ruse rube ruby}
           ]

  def test_xxx
    wch = WordChains.new

    @@tests.each do |et_chain|
      chain = wch.process(et_chain.first, et_chain.last)
      assert_equal et_chain, chain
    end
  end

end


