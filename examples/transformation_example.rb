# frozen_string_literal: true

require_relative "../lib/deprewriter"
require "debug"

class Legacy
  def old_method(arg)
    # ...
  end

  def new_method(arg)
    # ...
  end

  extend Deprewriter
  deprewrite :old_method, transform_with: "new_method({{arguments}}) {{block}}"

  class << self
    def old_method(arg)
      # ...
    end

    def new_method(arg)
      # ...
    end

    extend Deprewriter
    deprewrite :old_method, transform_with: "new_method({{arguments}}) {{block}}"
  end
end

# instance method rename
legecy = Legacy.new
legecy.old_method "Hello, world!" do
  1
end
Legacy.new.old_method("Hello, world!")

# class method rename
Legacy.old_method "Hello, world!" do
  1
end
