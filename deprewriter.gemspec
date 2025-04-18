# frozen_string_literal: true

require_relative "lib/deprewriter/version"

Gem::Specification.new do |spec|
  spec.name = "deprewriter"
  spec.version = Deprewriter::VERSION
  spec.authors = ["ohbarye"]
  spec.email = ["over.rye@gmail.com"]

  spec.summary = "An experimental gem that helps you rewrite deprecated code automatically."
  spec.homepage = "https://github.com/ohbarye/deprewriter"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ohbarye/deprewriter"
  spec.metadata["changelog_uri"] = "https://github.com/ohbarye/deprewriter/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "diffy"
  spec.add_dependency "logger"
  spec.add_dependency "node_query"
  spec.add_dependency "node_mutation"
  spec.add_dependency "prism"
  spec.add_dependency "prism_ext"
end
