#!/usr/bin/env ruby
require "rubygems"
require "bundler/setup"
require "benchmark"
require "segment_tree"

# generate a tree with +n+ number of intervals
def tree(n)
  SegmentTree.new list(n)
end
def list(n)
  (0..n).map { |num| [(num * 10)..(num + 1) * 10 - 1, num] }
end

puts "Pregenerating data..."
tests = [100, 1000, 10_000, 100_000, 1_000_000]

lists = Hash[tests.map { |n| [n, list(n)] }]
trees = Hash[tests.map { |n| [n, tree(n)] }]

puts "Done"
puts

puts "Building a tree of N intervals"
Benchmark.bmbm do |x|
  tests.each do |n|
    x.report(n.to_s) { tree(n) }
  end
end

puts "Finding matching interval in tree of N intervals"
Benchmark.bmbm do |x|
  tests.each do |n|
    t = trees[n]

    x.report(n.to_s) { t.find_first(rand(n)) }
  end
end

puts
puts "Finding matching interval in list of N intervals"
Benchmark.bmbm do |x|
  tests.each do |n|
    data = lists[n]

    x.report(n.to_s) { data.find { |range, _| range.include?(rand(n)) } }
  end
end