# SegmentTree [![Build Status](https://github.com/take-five/segment_tree/actions/workflows/ruby.yml/badge.svg?branch=master)](https://github.com/take-five/segment_tree/actions/workflows/ruby.yml)

Ruby implementation of [segment tree](http://en.wikipedia.org/wiki/Segment_tree) data structure.
Segment tree is a tree data structure for storing intervals, or segments. It allows querying which of the stored segments contain a given point. It is, in principle, a static structure; that is, its content cannot be modified once the structure is built.

Segment tree storage has the complexity of <tt>O(n)</tt>.
Segment tree querying has the complexity of <tt>O(log n)</tt>.

It's pretty fast on querying trees with ~ 10 millions segments, though building of such big tree will take long.
Internally it is not a tree - it is just a sorted array, and querying the tree is just a simple binary search (it was implemented as real tree in versions before 0.1.0, but these trees consumed a lot of memory).

## Installation

Add this line to your application's Gemfile:

    gem 'segment_tree'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install segment_tree

## Usage

Segment tree consists of segments (in Ruby it's <tt>Range</tt> objects) and corresponding values. The easiest way to build a segment tree is to create it from hash where segments are keys:
```ruby
tree = SegmentTree.new(1..10 => "a", 11..20 => "b", 21..30 => "c") # => #<SegmentTree:0xa47eadc @root=#<SegmentTree::Container:0x523f3b6 @range=1..30>>
```

After that you can query the tree of which segment contains a given point:
```ruby
tree.find(5) # => #<SegmentTree::Segment:0xa47ea8c @range=1..10, @value="a">
```

## Real world example

Segment tree can be used in applications where IP-address geocoding is needed.

```ruby
data = [
  [IPAddr.new('87.224.241.0/24').to_range, {:city => "YEKT"}],
  [IPAddr.new('195.58.18.0/24').to_range, {:city => "MSK"}]
  # and so on
]
ip_tree = SegmentTree.new(data)

client_ip = IPAddr.new("87.224.241.66")
ip_tree.find(client_ip).value # => {:city=>"YEKT"}
```

## Some benchmarks
```
Building a tree of N intervals

              user     system      total        real
100       0.000000   0.000000   0.000000 (  0.000143)
1000      0.000000   0.000000   0.000000 (  0.001094)
10000     0.010000   0.000000   0.010000 (  0.011446)
100000    0.110000   0.000000   0.110000 (  0.115025)
1000000   1.390000   0.000000   1.390000 (  1.387665)

Finding matching interval in tree of N intervals

              user     system      total        real
100       0.000000   0.000000   0.000000 (  0.000030)
1000      0.000000   0.000000   0.000000 (  0.000017)
10000     0.000000   0.000000   0.000000 (  0.000025)
100000    0.000000   0.000000   0.000000 (  0.000033)
1000000   0.000000   0.000000   0.000000 (  0.000028)

Finding matching interval in list of N intervals using Array.find

              user     system      total        real
100       0.000000   0.000000   0.000000 (  0.000055)
1000      0.000000   0.000000   0.000000 (  0.000401)
10000     0.010000   0.000000   0.010000 (  0.003971)
100000    0.010000   0.000000   0.010000 (  0.003029)
1000000   0.040000   0.000000   0.040000 (  0.038484)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## TODO
1. Fix README typos and grammatical errors (english speaking contributors are welcomed)
2. Implement C binding for MRI.

## LICENSE
Copyright (c) 2012 Alexei Mikhailov

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
