# frozen_string_literal: true

require "prism"
require_relative "deprewriter/version"

module Deprewriter
  autoload :Rewriter, "deprewriter/rewriter"
  autoload :CallSiteFinder, "deprewriter/call_site_finder"
  autoload :Transformer, "deprewriter/transformer"

  class << self
    def skip
      @skip ||= false
    end

    attr_writer :skip

    # Temporarily disable rewriting. Intended for tests only.
    def skip_during
      original = skip
      self.skip = true
      yield
    ensure
      self.skip = original
    end
  end

  def deprewrite(method_name, transform_with: nil)
    class_eval do
      old = "_deprecated_#{method_name}"
      alias_method old, method_name

      define_method method_name do |*args, &block|
        filepath, line = Gem.location_of_caller

        if !Deprewriter.skip && transform_with && File.exist?(filepath) && File.writable?(filepath)
          Deprewriter::Rewriter.rewrite_source(
            method_name,
            filepath,
            line,
            transform_with
          )
        else
          klass = is_a? Module
          target = klass ? "#{self}." : "#{self.class}#"
          warn "DEPRECATION WARNING: #{target}#{method_name} is deprecated\n#{target}#{method_name} called from #{filepath}:#{line}."
        end

        send old, *args, &block
      end
    end
  end
end
