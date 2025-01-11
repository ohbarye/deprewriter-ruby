# frozen_string_literal: true

require "prism"
require_relative "deprewriter/version"

module Deprewriter
  autoload :Configuration, "deprewriter/configuration"
  autoload :CallSiteFinder, "deprewriter/call_site_finder"
  autoload :Diff, "deprewriter/diff"
  autoload :Rewriter, "deprewriter/rewriter"
  autoload :Transformer, "deprewriter/transformer"

  class << self
    def config
      @config ||= Configuration.new
    end

    def configure
      yield config if block_given?
    end
  end

  # Marks a method as deprecated and sets up automatic code rewriting
  # @param method_name [Symbol] The name of the method to deprecate
  # @param from [String, nil] Pattern to match for transformation
  # @param to [String] Pattern to transform to
  def deprewrite(method_name, to:, from: nil)
    return if !Deprewriter.config.enabled?

    class_eval do
      old = "_deprecated_#{method_name}"
      alias_method old, method_name

      define_method method_name do |*args, &block|
        filepath, line = Gem.location_of_caller

        if File.exist?(filepath)
          source = File.read(filepath)
          rewritten_source = Rewriter.transform_source(source, method_name, line, to: to, from: from)
          diff = Diff.new(source, rewritten_source, filepath)

          if diff.different?
            target = is_a?(Module) ? "#{self}." : "#{self.class}#"

            case Deprewriter.config.mode
            in :rewrite
              if File.writable?(filepath)
                Deprewriter.config.logger.warn "DEPREWRITER: Dangerously trying to rewrite. It will rewrite a file to apply the deprecation and load the file"
                File.write(filepath, diff.rewritten_source)
                load filepath
              else
                Deprewriter.config.logger.error "DEPREWRITER: Failed to rewrite #{filepath} because it is not writable."
              end
            in :diff
              File.write(File.join(Dir.pwd, diff.id), diff.to_s)
            in :log
              Deprewriter.config.logger.warn "DEPREWRITER: #{target}#{method_name} usage at #{filepath}:#{line} is deprecated." \
                " You can apply the diff below to resolve the deprecation.\n#{diff}"
            end
          end
        end

        send old, *args, &block
      end
    end
  end
end
