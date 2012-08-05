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

t = tree(100_000)
n = rand(100_000)

RubyProf.start
t.find(n)
result = RubyProf.stop

# Print a flat profile to text
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)