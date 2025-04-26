# frozen_string_literal: true

require "logger"

module Deprewriter
  class Configuration
    attr_accessor :mode, :logger, :skip_redundant_rewrite

    def initialize
      @mode = case ENV["DEPREWRITER"]
      when nil
        :disabled
      when "log"
        :log
      when "diff"
        :diff
      when "dangerously_rewrite"
        :rewrite
      else
        :log # default
      end

      @logger = Logger.new($stdout)
      @skip_redundant_rewrite = true # Test purpose
    end

    def enabled?
      @mode != :disabled
    end
  end
end
