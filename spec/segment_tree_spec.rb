require 'spec_helper'
require 'segment_tree'

# subject { tree }
# it { should query(12).and_return("b") }
RSpec::Matchers.define :query do |key|
  chain :and_return do |expected|
    @expected = expected
    @expected = nil if @expected == :nothing
  end

  match do |tree|
    result = tree.find(key)
    result &&= result.value

    expect(result).to eq @expected
  end

  failure_message do |tree|
    result = tree.find(key)
    result &&= result.value

    "expected that #{tree.inspect} would return #{@expected.inspect} when querying #{key.inspect}, " +
    "but #{result.inspect} returned instead"
  end
end

describe SegmentTree do
  # some fixtures
  # [[0..9, "a"], [10..19, "b"], ..., [90..99, "j"]] - spanned intervals
  let(:sample_spanned) { (0..9).zip('a'..'j').map { |num, letter| [(num * 10)..(num + 1) * 10 - 1, letter] }.shuffle }
  # [[0..10, "a"], [10..20, "b"], ..., [90..100, "j"]] - partially overlapping intervals
  let(:sample_overlapping) { (0..9).zip('a'..'j').map { |num, letter| [(num * 10)..(num + 1) * 10 + 2, letter] }.shuffle }
  # [[0..5, "a"], [10..15, "b"], ..., [90..95, "j"]] - sparsed intervals
  let(:sample_sparsed) { (0..9).zip('a'..'j').map { |num, letter| [(num * 10)..(num + 1) * 10 - 5, letter] }.shuffle }

  # [[0..5, "a"], [0..7, "aa"], [10..15, "b"], [10..17, "bb"], ..., [90..97, "jj"]]
  let(:sample_overlapping2) do
    (0..9).zip('a'..'j').map do |num, letter|
      [(num * 10)..(num + 1) * 10 - 5, letter,
       (num * 10)..(num + 1) * 10 - 3, letter * 2]
    end.
    flatten.
    each_slice(2).
    to_a.
    shuffle
  end

  describe '.new' do
    context 'given a hash with ranges as keys' do
      let :data do
        {7..9 => 'a',
         4..6 => 'b',
         0..3 => 'c',
         10..12 => 'd'}
      end

      subject(:tree) { SegmentTree.new(data) }

      it { is_expected.to be_a SegmentTree }
    end

    context 'given an array of arrays' do
      let :data do
        [[0..3, 'a'],
         [4..6, 'b'],
         [7..9, 'c'],
         [10..12, 'd']].shuffle
      end

      subject(:tree) { SegmentTree.new(data) }

      it { is_expected.to be_a SegmentTree }
    end

    context 'given preordered data' do
      let :data do
        [[0..3, 'a'],
         [4..6, 'b'],
         [7..9, 'c'],
         [10..12, 'd']]
      end

      subject(:tree) { SegmentTree.new(data, true) }

      it { is_expected.to be_a SegmentTree }
      it { is_expected.to query(8).and_return('c') }
    end

    context 'given nor hash neither array' do
      it { expect{ SegmentTree.new(Object.new) }.to raise_error(ArgumentError) }
    end

    context 'given 1-dimensional array' do
      let :data do
        [0..3, 'a',
         4..6, 'b',
         7..9, 'c',
         10..12, 'd']
      end

      it { expect{ SegmentTree.new(data) }.to raise_error(ArgumentError) }
    end
  end

  describe 'querying' do
    context 'given spanned intervals' do
      subject { SegmentTree.new(sample_spanned) }

      it { is_expected.to query(12).and_return('b') }
      it { is_expected.to query(101).and_return(:nothing) }
    end

    context 'given partially overlapping intervals' do
      subject { SegmentTree.new(sample_overlapping) }

      it { is_expected.to query(11).and_return('a') }
    end

    context 'given sparsed intervals' do
      subject { SegmentTree.new(sample_sparsed) }

      it { is_expected.to query(12).and_return('b') }
      it { is_expected.to query(8).and_return(:nothing) }
    end

    context 'given hardly overlapping intervals' do
      subject { SegmentTree.new(sample_overlapping2) }

      it { is_expected.to query(12).and_return('b') }
      it { is_expected.to query(8).and_return(:nothing) }
    end
  end

  describe '#==' do
    subject { SegmentTree.new(sample_overlapping) }

    it { is_expected.to eq(SegmentTree.new(sample_overlapping)) }
    it { is_expected.not_to eq(SegmentTree.new(sample_overlapping2)) }

    it 'is equal when a range coerces' do
      expect(SegmentTree.new((1..2) => "a")).to eq(SegmentTree.new(((1.0)..(2.0)) => "a"))
    end

    it 'is equal when a value coerces' do
      expect(SegmentTree.new((1..2) => 1)).to eq(SegmentTree.new((1..2) => 1.0))
    end

    it "isn't equal when only a range is different" do
      expect(SegmentTree.new((1..2) => "a")).not_to eq(SegmentTree.new((1..3) => "a"))
    end

    it "isn't equal when only a value is different" do
      expect(SegmentTree.new((1..2) => "a")).not_to eq(SegmentTree.new((1..2) => "b"))
    end
  end

  describe '#eql?' do
    subject { SegmentTree.new(sample_overlapping) }

    it { is_expected.to be_eql(SegmentTree.new(sample_overlapping)) }
    it { is_expected.not_to be_eql(SegmentTree.new(sample_overlapping2)) }

    it "isn't equal when a range coerces" do
      expect(SegmentTree.new((1..2) => "a")).not_to be_eql(SegmentTree.new(((1.0)..(2.0)) => "a"))
    end

    it "isn't equal when a value coerces" do
      expect(SegmentTree.new((1..2) => 1)).not_to be_eql(SegmentTree.new((1..2) => 1.0))
    end

    it "isn't equal when only a range is different" do
      expect(SegmentTree.new((1..2) => "a")).not_to be_eql(SegmentTree.new((1..3) => "a"))
    end

    it "isn't equal when only a value is different" do
      expect(SegmentTree.new((1..2) => "a")).not_to be_eql(SegmentTree.new((1..2) => "b"))
    end
  end

  describe '#hash' do
    subject { SegmentTree.new(sample_overlapping).hash }

    it { is_expected.to eq(SegmentTree.new(sample_overlapping).hash) }
    it { is_expected.not_to eq(SegmentTree.new(sample_overlapping2).hash) }

    it "isn't equal when only a range is different" do
      expect(SegmentTree.new((1..2) => "a").hash).not_to eq(SegmentTree.new((1..3) => "a").hash)
    end

    it "isn't equal when only a value is different" do
      expect(SegmentTree.new((1..2) => "a").hash).not_to eq(SegmentTree.new((1..2) => "b").hash)
    end
  end

  describe 'marshaling' do
    it 'dumps and loads successfully' do
      aggregate_failures do
        [
          sample_spanned,
          sample_sparsed,
          sample_overlapping,
          sample_overlapping2,
        ].each do |sample|
          tree = SegmentTree.new(sample)
          dumped = Marshal.dump(tree)
          expect(Marshal.load(dumped)).to eq(tree)
        end
      end
    end
  end
end
