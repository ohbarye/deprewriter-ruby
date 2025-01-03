# frozen_string_literal: true

require_relative "call_site_finder"
require_relative "transformer"

module Deprewriter
  # Handles source code rewriting for deprecated methods
  module Rewriter
    module_function

    # Rewrites the source code at the specified location
    # @param method_name [Symbol] The name of the deprecated method
    # @param filepath [String] Path to the source file
    # @param line [Integer] Line number where the method is called
    # @param from [String, nil] Pattern to match for transformation
    # @param to [String] Pattern to transform to
    # @return [String] The rewritten source code
    def rewrite_source(method_name, filepath, line, to:, from: nil)
      source = File.read(filepath)
      rewritten_source = transform_source(source, method_name, line, from: from, to: to)

      # Write the changes back to the file if the source was modified
      if rewritten_source != source && !Deprewriter.skip
        File.write(filepath, rewritten_source)
        warn "DEPREWRITER: File #{filepath}:#{line} has been rewritten. The changes will take effect on the next execution."
      end

      rewritten_source
    end

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
