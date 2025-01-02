# frozen_string_literal: true

require_relative "../lib/deprewriter"
require "debug"

class Legacy
  def old_method(arg)
    puts "old instance method"
  end

  def new_method(arg)
    puts "new instance method"
  end

  extend Deprewriter
  deprewrite :old_method, transform_with: -> {
    rename(to: "new_method")
  }

  # Or using the Transformation DSL
  # transformation = Deprewriter::Transformation.new do
  #   rename from: :old_method, to: :new_method
  # end
  # deprewrite :old_method, transform_with: transformation

  class << self
    def old_method(arg)
      puts "old class method"
    end

    def new_method(arg)
      puts "new class method"
    end

    extend Deprewriter
    deprewrite :old_method, transform_with: -> { rename to: "new_method" }
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
