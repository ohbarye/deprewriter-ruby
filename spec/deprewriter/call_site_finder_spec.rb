# frozen_string_literal: true

RSpec.describe Deprewriter::CallSiteFinder do
  describe "#find" do
    it "finds method call at specified line" do
      source = <<~RUBY
        obj.other_method
        obj.target_method("arg")
        obj.other_method
      RUBY

      finder = described_class.new(:target_method, 2)
      node = finder.find(source)

      expect(node).to be_a(Prism::CallNode)
      expect(node.name).to eq(:target_method)
      expect(node.start_line).to eq(2)
    end

    it "returns nil when method call is not found" do
      source = "obj.other_method"

      finder = described_class.new(:target_method, 1)
      node = finder.find(source)

      expect(node).to be_nil
    end

    context "with from pattern" do
      it "finds method call matching the pattern" do
        source = 'obj.target_method("specific")'

        finder = described_class.new(:target_method, 1, from: ".call_node[name=target_method]")
        node = finder.find(source)

        expect(node).to be_a(Prism::CallNode)
      end

      it "finds method call matching the pattern" do
        source = 'obj.target_method("specific")'

        finder = described_class.new(:target_method, 1, from: {type: "call_node", name: "target_method"})
        node = finder.find(source)

        expect(node).to be_a(Prism::CallNode)
      end

      it "returns nil when method call does not match the pattern" do
        source = 'obj.target_method("different")'

        finder = described_class.new(:target_method, 1, from: ".call_node[name=unknown_method]")
        node = finder.find(source)

        expect(node).to be_nil
      end
    end
  end
end
