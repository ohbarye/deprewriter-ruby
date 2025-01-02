# frozen_string_literal: true

class DeprewriterSpec
  def foo
    "foo"
  end

  extend Deprewriter
  deprecate :foo, message: "foo is deprecated", transform_with: -> { "bar" }
end

RSpec.describe Deprewriter do
  it "has a version number" do
    expect(Deprewriter::VERSION).not_to be nil
  end

  it "deprewrites foo" do
    expect(DeprewriterSpec.new.foo).to eq("bar")
  end
end
