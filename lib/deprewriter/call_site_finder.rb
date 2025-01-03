# frozen_string_literal: true

module Deprewriter
  # Finds method call sites in source code
  class CallSiteFinder < Prism::Visitor
    # @return [Prism::CallNode, nil] The found method call node
    attr_reader :node

    # @param method_name [Symbol] The name of the method to find
    # @param line [Integer] Line number where the method is called
    def initialize(method_name, line)
      @method_name = method_name
      @line = line
      super()
    end

    # @param source [String] The source code to search in
    # @return [Prism::CallNode, nil] The found method call node
    def find(source)
      parsed_result = Prism.parse(source)
      parsed_result.value.statements.accept(self)
      node
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
