# frozen_string_literal: true

require "diffy"
require "digest"

module Deprewriter
  class Diff
    attr_reader :rewritten_source

    def initialize(source, rewritten_source, filepath, timestamp: Time.now)
      @source = source
      @rewritten_source = rewritten_source
      @filepath = filepath
      @timestamp = timestamp
    end

    def different?
      @source != @rewritten_source
    end

    def to_s
      @output ||= begin
        original_diff = Diffy::Diff.new(@source, @rewritten_source, include_diff_info: true, diff: "-u").to_s

        # Create a header to indicate a filepath since original_diff doesn't contain a correct filepath
        formatted_timestamp = @timestamp.strftime("%Y-%m-%d %H:%M:%S.%N %z")
        header = [
          "--- #{@filepath}\t#{formatted_timestamp}",
          "+++ #{@filepath}\t#{formatted_timestamp}"
        ].join("\n")

        [header, original_diff.lines[2..].join].join("\n")
      end
    end

    def id
      "deprewriter_#{Digest::MD5.hexdigest(to_s)}.diff"
    end
  end
end
