# == Synopsys
# Segment tree is a tree data structure for storing intervals, or segments.
# It allows querying which of the stored segments contain a given point.
# It is, in principle, a static structure; that is, its content cannot be modified once the structure is built.
#
# == Example
#   data = [
#     [IPAddr.new('87.224.241.0/24').to_range, {:city => "YEKT"}],
#     [IPAddr.new('195.58.18.0/24').to_range, {:city => "MSK"}]
#     # and so on
#   ]
#   ip_tree = SegmentTree.new(data)
#
#   client_ip = IPAddr.new("87.224.241.66")
#   ip_tree.find_first(client_ip).value # => {:city=>"YEKT"}
class SegmentTree
  # An abstract tree node
  class Node #:nodoc:all:
    attr_reader :begin, :end

    def initialize(*)
      @begin, @end = @range.begin, @range.end
    end
    protected :initialize

    def include?(x)
      @range.include?(x)
    end
  end

  # An elementary intervals or nodes container
  class Container < Node #:nodoc:all:
    extend Forwardable

    #attr_reader :left, :right

    # Node constructor, accepts both +Node+ and +Segment+
    def initialize(left, right)
      @left, @right = left, right
      @range = left.begin..(right || left).end

      super
    end

    # Find all intervals containing point +x+ within node's children. Returns array
    def find(x)
      [@left, @right].compact.
                      select { |node| node.include?(x) }.
                      map    { |node| node.find(x) }.
                      flatten
    end

    # Find first interval containing point +x+ within node's children
    def find_first(x)
      subset = [@left, @right].compact.find { |node| node.include?(x) }
      subset && subset.find_first(x)
    end

    # Do not expose left and right, otherwise output shall be too long on large trees
    def inspect
      "#<#{self.class.name}:0x#{object_id.to_s(16)} @range=#{@range.inspect}>"
    end
  end

  # An elementary interval
  class Segment < Node #:nodoc:all:
    attr_reader :value

    def initialize(range, value)
      raise ArgumentError, 'Range expected, %s given' % range.class.name unless range.is_a?(Range)

      @range, @value = range, value
      super
    end

    def find(x)
      [find_first(x)].compact
    end

    def find_first(x)
      @range.include?(x) ? self : nil
    end
  end

  # Build a segment tree from +data+.
  #
  # Data can be one of the following:
  # 1. Hash - a hash, where ranges are keys,
  #    i.e. <code>{(0..3) => some_value1, (4..6) => some_value2, ...}<code>
  # 2. 2-dimensional array - an array of arrays where first element of
  #    each element is range, and second is value:
  #    <code>[[(0..3), some_value1], [(4..6), some_value2] ...]<code>
  def initialize(data)
    # build elementary segments
    nodes = case data
      when Hash, Array, Enumerable then
        data.collect { |range, value| Segment.new(range, value) }
      else raise ArgumentError, '2-dim Array or Hash expected'
    end.sort! do |x, y|
      # intervals are sorted from left to right, from shortest to longest
      x.begin == y.begin ?
          x.end <=> y.end :
          x.begin <=> y.begin
    end

    # now build binary tree
    while nodes.length > 1
      nodes = nodes.each_slice(2).collect { |left, right| Container.new(left, right) }
    end

    # root node is first node or nil when tree is empty
    @root = nodes.first
  end

  # Find all intervals containing point +x+
  # @return [Array]
  def find(x)
    @root ? @root.find(x) : []
  end

  # Find first interval containing point +x+.
  # @return [Segment|NilClass]
  def find_first(x)
    @root && @root.find_first(x)
  end
end