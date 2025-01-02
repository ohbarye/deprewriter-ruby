# frozen_string_literal: true

module Deprewriter
  # Handles source code rewriting for deprecated methods
  module Rewriter
    module_function

    # Rewrites the source code at the specified location
    # @param method_name [Symbol] The name of the deprecated method
    # @param filepath [String] Path to the source file
    # @param line [Integer] Line number where the method is called
    # @param transformation [Deprewriter::Transformation] Transformation to apply
    # @return [void]
    def rewrite_source(method_name, filepath, line, transformation)
      return unless transformation.respond_to?(:call)

      source = File.read(filepath)
      rewritten_source = rewrite_method_call(source, method_name, line, transformation)

      # Write the changes back to the file if the source was modified
      if rewritten_source != source
        File.write(filepath, rewritten_source)
        warn "NOTE: File #{filepath}:#{line} has been rewritten. The changes will take effect on the next execution."
      end
    end

    # Rewrites a method call in the source code
    # @param source [String] The source code
    # @param method_name [Symbol] The name of the method to rewrite
    # @param line [Integer] Line number where the method is called
    # @param transformation [Deprewriter::Transformation] Transformation to apply
    # @return [String] The rewritten source code
    def rewrite_method_call(source, method_name, line, transformation)
      inspector = MethodCallInspector.new(method_name, line)
      parsed_result = Prism.parse(source)
      parsed_result.value.statements.accept(inspector)
      node = inspector.node
      return source if node.nil?

      # Replace the old code with new code
      before_node = source[0...(node.location.start_offset + node.message_loc.start_column)]
      new_code = transformation.call + (node.opening || " ") + node.arguments&.slice.to_s + node.closing.to_s + (node.block ? " " + node.block.slice : "")
      after_node = source[node.location.end_offset..]
      before_node + new_code + after_node
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
