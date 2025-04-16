require_relative "../lib/deprewriter"

class Legacy
  extend Deprewriter

  def old_method
    # This method is deprecated
    # Use new_method instead
  end

  def new_method
  end

  # Just rename method
  deprewrite :old_method,
    to: "new_method"

  def change_arg(arg1, arg2, message: "", to: "")
    # Passing arg1 and arg2 is deprecated
    # Use keyword args instead
  end

  # Rewrite method to use keyword args
  deprewrite :change_arg, to: <<~RULE
    change_arg(
      message: {{arguments.arguments.0}},
      to:      {{arguments.arguments.1}}
    )
  RULE
end
