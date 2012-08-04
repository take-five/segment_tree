#!/usr/bin/env ruby
require "rubygems"
require "bundler/setup"
require "segment_tree"
require 'ruby-prof'

# generate a tree with +n+ number of intervals
def tree(n)
  SegmentTree.new list(n)
end
def list(n)
  (0..n).map { |num| [(num * 10)..(num + 1) * 10 - 1, num] }
end

t = tree(10_000)
n = rand(10_000)

RubyProf.start
t.find_first(n)
result = RubyProf.stop

# Print a flat profile to text
printer = RubyProf::FlatPrinterWithLineNumbers.new(result)
printer.print(STDOUT)