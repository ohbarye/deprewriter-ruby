# frozen_string_literal: true

module Deprewriter
  # Handles source code rewriting for deprecated methods
  module Rewriter
    module_function

    # @param source [String] The source code
    # @param method_name [Symbol] The name of the method to rewrite
    # @param line [Integer] Line number where the method is called
    # @param from [String, nil] Pattern to match for transformation
    # @param to [String] Pattern to transform to
    # @return [String] The rewritten source code
    def transform_source(source, method_name, line, to:, from: nil)
      node = CallSiteFinder.new(method_name, line, from: from).find(source)
      Transformer.new(source, node, to).transform
    end
  end
end
