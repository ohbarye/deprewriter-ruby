module Deprewriter
  # Handles transformation rules for deprecated methods
  class Transformation
    # Initializes a new Transformation instance
    # @yield [void] Block containing transformation rules
    def initialize(&block)
      @rules = []
      instance_exec(&block) if block_given?
    end

    # Defines a rule to rename a method
    # @param to [Symbol, String] The new method name
    # @return [void]
    def rename(to:)
      @rules << -> { to.to_s }
    end

    # Executes all transformation rules
    # @return [String] The transformed code
    def call
      @rules.map(&:call).join("\n")
    end
  end
end
