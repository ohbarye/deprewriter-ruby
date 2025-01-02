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

```ruby
require "deprewriter"

class Legacy
  def deprecated_instance_method
    # ...
  end

  def new_instance_method
    # ...
  end

  extend Gem::Deprecate
  deprewrite :deprecated_instance_method, transform_with: -> { "deprecated_instance_method -> new_instance_method" }

  class << self
    def deprecated_klass_method
      # ...
    end

    def new_klass_method
      # ...
    end

    extend Gem::Deprecate
    deprewrite :deprecated_klass_method, transform_with: -> { "deprecated_klass_method -> new_klass_method" }
  end
end
```

## TODO

- [ ] Complete major deprecation scenarios
  - [ ] Rename method
  - [ ] Remove argument(-s)
  - [ ] Add argument(-s)
  - [ ] Change receiver
  - [ ] Split method
  - [ ] Delete method
  - [ ] Push down
  - [ ] Deprecate class
  - [ ] Complex replacement
- [ ] Decide DSL for transformation rules

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/deprewriter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/deprewriter/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Deprewriter project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/deprewriter/blob/master/CODE_OF_CONDUCT.md).
