# frozen_string_literal: true

RSpec.describe Deprewriter::Transformer do
  describe "#transform" do
    it "transforms method call with arguments" do
      source = 'obj.old_method("arg")'
      node = Deprewriter::CallSiteFinder.new(:old_method, 1).find(source)

      transformer = described_class.new(source, node, "new_method({{arguments}})")
      result = transformer.transform

      expect(result).to eq('obj.new_method("arg")')
    end

    it "transforms method call with block" do
      source = <<~RUBY
        obj.old_method("arg") do
          puts "hello"
        end
      RUBY

      node = Deprewriter::CallSiteFinder.new(:old_method, 1).find(source)
      transformer = described_class.new(source, node, "new_method({{arguments}}) {{block}}")
      result = transformer.transform

      expect(result).to eq(<<~RUBY)
        obj.new_method("arg") do
          puts "hello"
        end
      RUBY
    end
  end
end
