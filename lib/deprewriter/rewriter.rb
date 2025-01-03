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
    # @param transform_with [String] Transformation to apply
    # @return [String] The rewritten source code
    def rewrite_source(method_name, filepath, line, transform_with)
      source = File.read(filepath)
      rewritten_source = transform_source(source, method_name, line, transform_with)

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
    # @param transform_with [String] Transformation to apply
    # @return [String] The rewritten source code
    def transform_source(source, method_name, line, transform_with)
      finder = CallSiteFinder.new(method_name, line)
      node = finder.find(source)

      transformer = Transformer.new(source, node, transform_with)
      transformer.transform
    end
  end
end
