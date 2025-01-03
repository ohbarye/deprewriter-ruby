# frozen_string_literal: true

require "node_query"

module Deprewriter
  # Finds method call sites in source code
  class CallSiteFinder < Prism::Visitor
    # @return [Prism::CallNode, nil] The found method call node
    # @param method_name [Symbol] The name of the method to find
    # @param line [Integer] Line number where the method is called
    # @param from [String, nil] Pattern to match for transformation
    def initialize(method_name, line, from: nil)
      @method_name = method_name
      @line = line
      @node_query = from ? NodeQuery.new(from, adapter: :prism) : nil
      super()
    end

    # @param source [String] The source code to search in
    # @return [Prism::CallNode, nil] The found method call node
    def find(source)
      parsed_result = Prism.parse(source)
      parsed_result.value.statements.accept(self)
      @node
    end

    # Visits a call node in the AST
    # @param node [Prism::CallNode] The call node to visit
    # @return [void]
    def visit_call_node(node)
      if node.name == @method_name && node.start_line == @line
        if @node_query
          matched = @node_query.query_nodes(node, {including_self: true, stop_at_first_match: true, recursive: true})
          @node = matched.first if matched.any?
        else
          @node = node
        end
      end

      super
    end
  end
end
