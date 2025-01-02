# frozen_string_literal: true

require "prism"

module Deprewriter
  autoload :VERSION, "deprewriter/version"
  autoload :Rewriter, "deprewriter/rewriter"

  # Marks a method as deprecated and sets up automatic code rewriting
  # @param method_name [Symbol] The name of the method to deprecate
  # @param message [String, nil] Custom deprecation message
  # @param transform_with [String] Transformation to apply to the deprecated method calls. @see https://synvert-hq.github.io/synvert-core-ruby/Synvert/Core/Rewriter/Instance.html#replace_with-instance_method
  # @return [void]
  def deprewrite(method_name, message: nil, transform_with: nil)
    class_eval do
      old = "_deprecated_#{method_name}"
      alias_method old, method_name

      define_method method_name do |*args, &block|
        filepath, line = Gem.location_of_caller

        if transform_with && File.exist?(filepath) && File.writable?(filepath)
          Deprewriter::Rewriter.rewrite_source(method_name, filepath, line, transform_with)
        else
          klass = is_a? Module
          target = klass ? "#{self}." : "#{self.class}#"
          warn message || "DEPRECATION WARNING: #{target}#{method_name} is deprecated\n#{target}#{method_name} called from #{filepath}:#{line}."
        end

        send old, *args, &block
      end
    end
  end
end
