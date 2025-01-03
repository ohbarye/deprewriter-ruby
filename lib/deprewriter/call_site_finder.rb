# frozen_string_literal: true

module Deprewriter
  # Finds method call sites in source code
  class CallSiteFinder < Prism::Visitor
    # @return [Prism::CallNode, nil] The found method call node
    attr_reader :node

    # @param method_name [Symbol] The name of the method to find
    # @param line [Integer] Line number where the method is called
    # @param from [String, nil] Pattern to match for transformation
    def initialize(method_name, line, from: nil)
      @method_name = method_name
      @line = line
      @from = from
      super()
    end

    # @param source [String] The source code to search in
    # @return [Prism::CallNode, nil] The found method call node
    def find(source)
      parsed_result = Prism.parse(source)
      parsed_result.value.statements.accept(self)
      return nil unless node
      return nil unless matches_pattern?
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

    private

    def matches_pattern?
      return true if @from.nil?

      # TODO: Implement to check if call node matches the pattern given client
      true
    end
  end
end
