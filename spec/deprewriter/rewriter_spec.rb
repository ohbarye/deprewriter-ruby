# frozen_string_literal: true

RSpec.describe Deprewriter::Rewriter do
  describe ".transform_source" do
    it "rewrites a simple method call" do
      source = <<~RUBY
        obj.old_method("Hello")
      RUBY

      result = described_class.transform_source(
        source,
        :old_method,
        1,
        to: "new_method({{arguments}})"
      )

      expect(result).to eq <<~RUBY
        obj.new_method("Hello")
      RUBY
    end

    it "rewrites a method call with a block" do
      source = <<~RUBY
        obj.old_method("Hello") do
          puts "world"
        end
      RUBY

      result = described_class.transform_source(
        source,
        :old_method,
        1,
        to: "new_method({{arguments}}) {{block}}"
      )

      expect(result).to eq <<~RUBY
        obj.new_method("Hello") do
          puts "world"
        end
      RUBY
    end

    it "only rewrites the method call at the specified line" do
      source = <<~RUBY
        obj.old_method("First")
        obj.old_method("Second")
      RUBY

      result = described_class.transform_source(
        source,
        :old_method,
        2,
        to: "new_method({{arguments}})"
      )

      expect(result).to eq <<~RUBY
        obj.old_method("First")
        obj.new_method("Second")
      RUBY
    end
  end
end
