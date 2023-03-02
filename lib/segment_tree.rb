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
#   ip_tree.find(client_ip).value # => {:city=>"YEKT"}
class SegmentTree
  # An elementary interval
  class Segment #:nodoc:all:
    attr_reader :range, :value

    def initialize(range, value)
      raise ArgumentError, 'Range expected, %s given' % range.class.name unless range.is_a?(Range)

      @range, @value = range, value
    end

    # segments are sorted from left to right, from shortest to longest
    def <=>(other)
      case cmp = @range.begin <=> other.range.begin
        when 0 then @range.end <=> other.range.end
        else cmp
      end
    end

    def ==(other)
      other.is_a?(self.class) &&
        @range == other.range &&
        @value == other.value
    end

    def eql?(other)
      other.is_a?(self.class) &&
        @range.eql?(other.range) &&
        @value.eql?(other.value)
    end

    def hash
      [@range, @value].hash
    end
  end

  attr_reader :segments

  # Build a segment tree from +data+.
  #
  # Data can be one of the following:
  # 1. Hash - a hash, where ranges are keys,
  #    i.e. <code>{(0..3) => some_value1, (4..6) => some_value2, ...}<code>
  # 2. 2-dimensional array - an array of arrays where first element of
  #    each element is range, and second is value:
  #    <code>[[(0..3), some_value1], [(4..6), some_value2] ...]<code>
  #
  # You can pass optional argument +sorted+.
  # If +sorted+ is true then tree consider that data already sorted in proper order.
  # Use it at your own risk!
  def initialize(data, sorted = false)
    # build elementary segments
    @segments = case data
      when Hash, Array, Enumerable then
        data.collect { |range, value| Segment.new(range, value) }
      else raise ArgumentError, '2-dim Array or Hash expected'
    end

    @segments.sort! unless sorted
  end

  # Find first interval containing point +x+.
  # @return [Segment|NilClass]
  def find(x)
    return nil if x.nil?
    low = 0
    high = @segments.size - 1
    while low <= high
      mid = (low + high) / 2

      case matches?(x, low, high, mid)
        when -1 then high = mid - 1
        when 1 then low = mid + 1
        when 0 then return @segments[mid]
        else return nil
      end
    end
    nil
  end

  def inspect
    if @segments.size > 0
      "SegmentTree(#{@segments.first.range.begin}..#{@segments.last.range.end})"
    else
      "SegmentTree(empty)"
    end
  end

  def ==(other)
    other.is_a?(self.class) && @segments == other.segments
  end

  def eql?(other)
    other.is_a?(self.class) && @segments.eql?(other.segments)
  end

  def hash
    @segments.hash
  end

  private
  def matches?(x, low_idx, high_idx, idx) #:nodoc:
    low, high = @segments[low_idx], @segments[high_idx]
    segment   = @segments[idx]
    left      = idx > 0 && @segments[idx - 1]
    right     = idx < @segments.size - 1 && @segments[idx + 1]

    case
      when left && low.range.begin <= x && x <= left.range.end then -1
      when segment.range.begin <=x && x <= segment.range.end then 0
      when right && right.range.begin <=x && x <= high.range.end then 1
      else nil
    end
  end
end