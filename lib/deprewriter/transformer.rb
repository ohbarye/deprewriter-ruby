# frozen_string_literal: true

require "node_mutation"

module Deprewriter
  # Handles source code transformation for deprecated methods
  class Transformer
    # @param source [String] The source code
    # @param node [Prism::CallNode] The node to transform
    # @param transform_with [String] The transformation pattern
    def initialize(source, node, transform_with)
      @source = source
      @node = node
      @transform_with = transform_with
    end

    # @return [String] The transformed source code
    def transform
      return @source if @node.nil?

      before_node = @source[0...@node.location.start_offset]
      new_code = transform_call_node
      after_node = @source[@node.location.end_offset..]
      before_node + new_code + after_node
    end

    private

    def transform_call_node
      adapter = NodeMutation::PrismAdapter.new
      receiver_code = @node.receiver ? "#{@node.receiver.slice}." : ""

      call_node = Prism.parse(@node.slice.gsub(receiver_code, "")).value.statements.body.first
      receiver_code + adapter.rewritten_source(call_node, @transform_with)
    end
  end
end
