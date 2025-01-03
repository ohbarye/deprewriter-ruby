# frozen_string_literal: true

RSpec.describe Deprewriter do
  it "transforms deprecated method calls" do
    klass = Class.new do
      def old_method(arg)
        "old: #{arg}"
      end

      def new_method(arg)
        "new: #{arg}"
      end

      extend Deprewriter
      deprewrite :old_method, to: "new_method({{arguments}})"
    end

    Deprewriter.skip_during do
      instance = klass.new
      expect(instance.old_method("test")).to eq "old: test"
    end
  end

  it "handles blocks in transformations" do
    klass = Class.new do
      def old_method(arg, &block)
        "old: #{arg}, block: #{block.call}"
      end

      def new_method(arg, &block)
        "new: #{arg}, block: #{block.call}"
      end

      extend Deprewriter
      deprewrite :old_method, to: "new_method({{arguments}}) {{block}}"
    end

    Deprewriter.skip_during do
      instance = klass.new
      result = instance.old_method("test") { "block content" }
      expect(result).to eq "old: test, block: block content"
    end
  end
end
