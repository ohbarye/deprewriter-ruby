# Deprewriter

[![Gem Version](https://badge.fury.io/rb/deprewriter.svg)](https://rubygems.org/gems/deprewriter)
[![Build Status](https://github.com/ohbarye/deprewriter/actions/workflows/main.yml/badge.svg)](https://github.com/ohbarye/deprewriter/actions/workflows/main.yml)
[![RubyDoc](https://img.shields.io/badge/%F0%9F%93%9ARubyDoc-documentation-informational.svg)](https://www.rubydoc.info/gems/deprewriter)

Deprewriter is an experimental gem that helps you rewrite deprecated code automatically.

When library authors deprecate methods, they typically notify users through documentation and deprecation warnings at runtime. Users then need to manually update their code to stop using deprecated methods and switch to recommended alternatives. Deprewriter automates this process.

This project is inspired by Deprewriter in the Pharo programming language. For more details, see "[Deprewriter: On the fly rewriting method deprecations.](https://inria.hal.science/hal-03563605/document#page=2.15&gsr=0)" (2022).

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add deprewriter
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install deprewriter
```

## Usage

Let's say a library code has a class `Legacy` with a deprecated method `old_method` and a new method `new_method`. The code owner can declare `deprewrite` with transformation rules.

```ruby
# Library code
require "deprewriter"

class Legacy
  def old_method(arg)
    # ...
  end

  def new_method(arg)
    # ...
  end

  extend Deprewriter
  deprewrite :old_method, to: "new_method({{arguments}})"
end
```

And then, when a user program calls `old_method` with the following code:

```ruby
# User code
legacy = Legacy.new
legacy.old_method(arg) # This line will trigger Deprewriter
```

If a user program runs with `DEPREWRITER=log` environment variable...

```bash
DEPREWRITER=1 ruby your_script.rb
```

...it will log a warning with the suggested changes to rewrite the code:

```diff
legacy = Legacy.new
-legacy.old_method(arg)
+legacy.new_method(arg)
```

### For code owners

You can also specify a pattern to match for transformation using the `from` option:

```ruby
deprewrite :old_method,
  from: '.call_node[name=old_method]', # Rewrite calls only when matched
  to: 'new_method({{arguments}})'
```

The syntax of transformation rules is taken from [Synvert](https://synvert.net/) and it uses [Prism](https://ruby.github.io/prism/) to parse and rewrite the source code. Variables in a transformation rule string like `{{arguments}}` and `{{block}}` etc. correspond to methods provided by Prism node.

For more details, see:

- [Synvert::Core::Rewriter::Instance#replace_with](https://synvert-hq.github.io/synvert-core-ruby/Synvert/Core/Rewriter/Instance.html#replace_with-instance_method).
- [Prism::CallNode](https://docs.ruby-lang.org/en/master/Prism/CallNode.html)

### For client users

Deprewriter can be configured either through environment variables or programmatically. There are three modes of operation:

### Environment Variable Configuration

Set the `DEPREWRITER` environment variable to one of these values:

- `log` - For logging mode. Logs deprecation warnings and shows diffs (default)
- `diff` - For diff mode. Creates diff files for each deprecation
- `dangerously_rewrite` - For rewrite mode. Automatically rewrites files (use with caution!)
- If not set, Deprewriter will be disabled

Example:

```ruby
# Deprewriter is disabled
ruby your_script.rb

# Deprewriter is enabled as log mode.
DEPREWRITER=1 ruby your_script.rb
DEPREWRITER=log ruby your_script.rb

# Deprewriter is enabled as diff mode.
DEPREWRITER=diff ruby your_script.rb

# Deprewriter is enabled as rewrite mode.
DEPREWRITER=dangerously_rewrite ruby your_script.rb
```

### Programmatic Configuration

You can configure Deprewriter programmatically using the configuration block:

```ruby
Deprewriter.configure do |config|
  # Set the mode (:log, :diff, :rewrite, or :disabled)
  config.mode = :log

  # Configure custom logger (defaults to STDOUT)
  config.logger = Logger.new('deprewriter.log')
end
```

## Mechanism

Deprewriter determines caller code at runtime and attempts to rewrite it according to predefined transformation rules, though the actual rewriting depends on the configured mode and file permissions.

1. Library authors define deprecation rules for methods they want to deprecate, along with transformation rules specifying how the code should be rewritten.
2. When the program loads, Deprewriter renames the deprecated method to `_deprecated_foo` and dynamically defines a new method `foo`. This is similar to how [`Gem::Deprecate.deprecate`](https://github.com/ruby/ruby/blob/v3_4_1/lib/rubygems/deprecate.rb#L103-L121) works.
3. When the deprecated method `foo` is called by user code, Deprewriter analyzes the caller's code and generates a transformation according to the rules. Depending on the configured mode. In all cases, it calls the original `_deprecated_foo` to preserve the original behavior.
4. If the file was successfully rewritten, subsequent executions will use the transformed code. Otherwise, the deprecated method will continue to be called and generate warnings/diffs on each invocation.

## TODO

- [x] Complete major deprecation scenarios
  - Rename method
  - Remove argument(-s)
  - Add argument(-s)
- [x] Decide DSL for transformation rules
  - [x] Use Synvert for now
- [x] Testable code structure and write tests

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ohbarye/deprewriter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/deprewriter/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Deprewriter project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/deprewriter/blob/master/CODE_OF_CONDUCT.md).
