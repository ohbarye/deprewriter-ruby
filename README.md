# Deprewriter

[![Gem Version](https://badge.fury.io/rb/deprewriter.svg)](https://rubygems.org/gems/deprewriter)
[![Build Status](https://github.com/ohbarye/deprewriter/actions/workflows/main.yml/badge.svg)](https://github.com/ohbarye/deprewriter/actions/workflows/main.yml)
[![RubyDoc](https://img.shields.io/badge/%F0%9F%93%9ARubyDoc-documentation-informational.svg)](https://www.rubydoc.info/gems/deprewriter)

Deprewriter is an experimental gem that helps you rewrite deprecated code automatically.

When library authors deprecate methods, they typically notify users through documentation and deprecation warnings at runtime. Users then need to manually update their code to stop using deprecated methods and switch to recommended alternatives. Deprewriter automates this process.

This project is inspired by Deprewriter in the Pharo programming language. For more details, see "[Deprewriter: On the fly rewriting method deprecations.](https://inria.hal.science/hal-03563605/document#page=2.15&gsr=0)" (2022).

## Mechanism

Deprewriter rewrites caller code on the fly at runtime according to predefined transformation rules.

1. Library authors define deprecation rules for methods they want to deprecate, along with transformation rules specifying how the code should be rewritten.
2. When the program loads, Deprewriter renames the deprecated method to `_deprecated_foo` and dynamically defines a new method `foo`. This is similar to how [`Gem::Deprecate.deprecate`](https://github.com/ruby/ruby/blob/v3_4_1/lib/rubygems/deprecate.rb#L103-L121) works.
3. When the deprecated method `foo` is called by user code, Deprewriter rewrites the caller's code according to the transformation rules. After loading the rewritten code, it calls the original `_deprecated_foo`.
4. From then on, the next execution of the rewritten method will execute the transformed code, and as such, the deprecated method will not be invoked from that call site anymore.

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

Let's say you have a class `Legacy` with a deprecated method `old_method` and a new method `new_method`. You can declare `deprewrite` with transformation rules.

```ruby
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

When a user program calls `old_method`, it will be rewritten to `new_method`.

```ruby
legacy = Legacy.new
legacy.old_method(arg) # This line will be rewritten
```

```diff
legacy = Legacy.new
-legacy.old_method(arg)
+legacy.new_method(arg)
```

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

## TODO

- [ ] Complete major deprecation scenarios
  - [x] Rename method
  - [ ] Remove argument(-s)
  - [ ] Add argument(-s)
  - [ ] Change receiver
  - [ ] Split method
  - [ ] Delete method
  - [ ] Push down
  - [ ] Deprecate class
  - [ ] Complex replacement
- [x] Decide DSL for transformation rules
  - [x] Use Synvert for now
- [ ] Testable code structure and write tests

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ohbarye/deprewriter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/deprewriter/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Deprewriter project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/deprewriter/blob/master/CODE_OF_CONDUCT.md).
