require_relative "legacy"

legecy = Legacy.new

# This method will be rewritten to use keyword args
legecy.change_arg("Hello", "RubyKaigi")
