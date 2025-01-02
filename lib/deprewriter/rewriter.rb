# frozen_string_literal: true

require "node_mutation"

module Deprewriter
  # Handles source code rewriting for deprecated methods
  module Rewriter
    module_function

    # Rewrites the source code at the specified location
    # @param method_name [Symbol] The name of the deprecated method
    # @param filepath [String] Path to the source file
    # @param line [Integer] Line number where the method is called
    # @param transform_with [String] Transformation to apply
    # @return [void]
    def rewrite_source(method_name, filepath, line, transform_with)
      source = File.read(filepath)
      rewritten_source = rewritten_source(source, method_name, line, transform_with)

      # Write the changes back to the file if the source was modified
      if rewritten_source != source
        File.write(filepath, rewritten_source)
        warn "DEPREWRITER: File #{filepath}:#{line} has been rewritten. The changes will take effect on the next execution."
      end
    end

    # Rewrites a method call in the source code
    # @param source [String] The source code
    # @param method_name [Symbol] The name of the method to rewrite
    # @param line [Integer] Line number where the method is called
    # @param transform_with [String] Transformation to apply
    # @return [String] The rewritten source code
    def rewritten_source(source, method_name, line, transform_with)
      inspector = MethodCallInspector.new(method_name, line)
      parsed_result = Prism.parse(source)
      parsed_result.value.statements.accept(inspector)
      node = inspector.node
      return source if node.nil?

      before_node = source[0...node.location.start_offset]
      new_code = rewritten_call_node(node, transform_with)
      after_node = source[node.location.end_offset..]
      before_node + new_code + after_node
    end

    def rewritten_call_node(node, transform_with)
      adapter = NodeMutation::PrismAdapter.new
      receiver_code = node.receiver ? "#{node.receiver.slice}." : ""

      call_node = Prism.parse(node.slice.gsub(receiver_code, "")).value.statements.body.first
      receiver_code + adapter.rewritten_source(call_node, transform_with)
    end

    # Visitor class to find method calls in the AST
    class MethodCallInspector < Prism::Visitor
      # @return [Prism::CallNode, nil] The found method call node
      attr_reader :node

      # @param method_name [Symbol] The name of the method to find
      # @param line [Integer] Line number where the method is called
      def initialize(method_name, line)
        @method_name = method_name
        @line = line
        super()
      end

      # Visits a call node in the AST
      # @param node [Prism::CallNode] The call node to visit
      # @return [void]
      def visit_call_node(node)
        if node.name == @method_name && node.start_line == @line
          @node = node
        end

        super
      end
    end
  end
end
