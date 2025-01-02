# frozen_string_literal: true

require "prism"
require_relative "deprewriter/version"
require_relative "deprewriter/rewriter"
require_relative "deprewriter/transformation"

module Deprewriter
  # Marks a method as deprecated and sets up automatic code rewriting
  # @param method_name [Symbol] The name of the method to deprecate
  # @param message [String, nil] Custom deprecation message
  # @param transform_with [#call, nil] Transformation to apply to the deprecated method calls
  # @return [void]
  def deprewrite(method_name, message: nil, transform_with: nil)
    class_eval do
      old = "_deprecated_#{method_name}"
      alias_method old, method_name

      define_method method_name do |*args, &block|
        klass = is_a? Module
        target = klass ? "#{self}." : "#{self.class}#"

        filepath, line = Gem.location_of_caller

        # Only rewrite if the file exists and is writable
        if transform_with && File.exist?(filepath) && File.writable?(filepath)
          transformation = Transformation.new(&transform_with)
          Deprewriter::Rewriter.rewrite_source(method_name, filepath, line, transformation)
        end

        warn message || "DEPRECATION WARNING: #{target}#{method_name} is deprecated\n#{target}#{method_name} called from #{filepath}:#{line}."

        send old, *args, &block
      end
    end
  end
end
