# frozen_string_literal: true

RSpec.describe Deprewriter::Diff do
  let(:source) { "def hello\n  puts 'Hello'\nend\n" }
  let(:rewritten_source) { "def hello\n  puts 'Hello, World!'\nend\n" }
  let(:filepath) { "example.rb" }
  let(:timestamp) { Time.new(2024, 1, 1, 12, 0, 0, "+09:00") }
  let(:diff) { described_class.new(source, rewritten_source, filepath, timestamp:) }

  describe "#different?" do
    context "when sources are different" do
      it "returns true" do
        expect(diff).to be_different
      end
    end

    context "when sources are same" do
      let(:rewritten_source) { source }

      it "returns false" do
        expect(diff).not_to be_different
      end
    end
  end

  describe "#to_s" do
    it "generates diff with filepath" do
      result = diff.to_s

      expect(result).to eq(<<~DIFF)
        --- example.rb\t2024-01-01 12:00:00.000000000 +0900
        +++ example.rb\t2024-01-01 12:00:00.000000000 +0900
        @@ -1,3 +1,3 @@
         def hello
        -  puts 'Hello'
        +  puts 'Hello, World!'
         end
      DIFF
    end
  end

  describe "#id" do
    it "generates consistent hash for the same diff" do
      first_id = diff.id
      second_id = diff.id

      expect(first_id).to eq(second_id)
      expect(first_id).to match(/\Adeprewriter_[a-f0-9]{32}\.patch\z/)
    end

    it "generates different hash for different diffs" do
      diff1 = described_class.new("a", "b", filepath, timestamp:)
      diff2 = described_class.new("x", "y", filepath, timestamp:)

      expect(diff1.id).not_to eq(diff2.id)
    end
  end
end
