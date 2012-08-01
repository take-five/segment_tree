require "spec_helper"
require "segment_tree"

describe SegmentTree do
  # some fixtures
  # [[0..9, "a"], [10..19, "b"], ..., [90..99, "j"]] - spanned intervals
  let(:sample_spanned) { (0..9).zip("a".."j").map { |num, letter| [(num * 10)..(num + 1) * 10 - 1, letter] } }
  # [[0..12, "a"], [10..22, "b"], ..., [90..102, "j"]] - partially overlapping intervals
  let(:sample_overlapping) { (0..9).zip("a".."j").map { |num, letter| [(num * 10)..(num + 1) * 10 + 2, letter] } }
  # [[0..5, "a"], [10..15, "b"], ..., [90..95, "j"]] - sparsed intervals
  let(:sample_sparsed) { (0..9).zip("a".."j").map { |num, letter| [(num * 10)..(num + 1) * 10 - 5, letter] } }

  describe ".new" do
    context "given a hash with ranges as keys" do
      let :data do
        {0..3 => "a",
         4..6 => "b",
         7..9 => "c",
         10..12 => "d"}
      end

      subject(:tree) { SegmentTree.new(data) }

      it { should be_a SegmentTree }

      it "should have a root" do
        root = tree.instance_variable_get :@root
        root.should be_a SegmentTree::Container
      end
    end

    context "given an array of arrays" do
      let :data do
        [[0..3, "a"],
         [4..6, "b"],
         [7..9, "c"],
         [10..12, "d"]]
      end

      subject(:tree) { SegmentTree.new(data) }

      it { should be_a SegmentTree }

      it "should have a root" do
        root = tree.instance_variable_get :@root
        root.should be_a SegmentTree::Container
      end
    end

    context "given nor hash neither array" do
      it { expect{ SegmentTree.new(Object.new) }.to raise_error(ArgumentError) }
    end

    context "given 1-dimensional array" do
      let :data do
        [0..3, "a",
         4..6, "b",
         7..9, "c",
         10..12, "d"]
      end

      it { expect{ SegmentTree.new(data) }.to raise_error(ArgumentError) }
    end
  end

  describe "#find" do
    context "given spanned intervals" do
      let(:tree) { SegmentTree.new(sample_spanned) }

      context "and looking up for existent point" do
        subject { tree.find 12 }

        it { should be_a Array }
        it { should have_exactly(1).item }
        its(:first) { should be_a SegmentTree::Segment }
        its('first.value') { should eq 'b' }
      end

      context "and looking up for non-existent point" do
        subject { tree.find 101 }

        it { should be_a Array }
        it { should be_empty }
      end
    end

    context "given partially overlapping intervals" do
      let(:tree) { SegmentTree.new(sample_overlapping) }

      context "and looking up for existent point" do
        subject { tree.find 11 }

        it { should be_a Array }
        it { should have_exactly(2).item }
        its(:first) { should be_a SegmentTree::Segment }
        its('first.value') { should eq 'a' }
        its(:last) { should be_a SegmentTree::Segment }
        its('last.value') { should eq 'b' }
      end
    end

    context "given sparsed intervals" do
      let(:tree) { SegmentTree.new(sample_sparsed) }

      context "and looking up for existent point" do
        subject { tree.find 12 }

        it { should be_a Array }
        it { should have_exactly(1).item }
        its(:first) { should be_a SegmentTree::Segment }
        its('first.value') { should eq 'b' }
      end

      context "and looking up for non-existent point" do
        subject { tree.find 8 }

        it { should be_a Array }
        it { should be_empty }
      end
    end
  end

  describe "#find_first" do
    context "given spanned intervals" do
      let(:tree) { SegmentTree.new(sample_spanned) }

      context "and looking up for existent point" do
        subject { tree.find_first 12 }

        it { should be_a SegmentTree::Segment }
        its(:value) { should eq 'b' }
      end

      context "and looking up for non-existent point" do
        subject { tree.find_first 101 }

        it { should be_nil }
      end
    end

    context "given partially overlapping intervals" do
      let(:tree) { SegmentTree.new(sample_overlapping) }

      context "and looking up for existent point" do
        subject { tree.find_first 11 }

        it { should be_a SegmentTree::Segment }
        its(:value) { should eq 'a' }
      end
    end

    context "given sparsed intervals" do
      let(:tree) { SegmentTree.new(sample_sparsed) }

      context "and looking up for existent point" do
        subject { tree.find_first 12 }

        it { should be_a SegmentTree::Segment }
        its(:value) { should eq 'b' }
      end

      context "and looking up for non-existent point" do
        subject { tree.find_first 8 }

        it { should be_nil }
      end
    end
  end
end