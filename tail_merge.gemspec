# frozen_string_literal: true

require_relative "lib/tail_merge/version"

Gem::Specification.new do |spec|
  spec.name = "tail_merge"
  spec.version = TailMerge::VERSION
  spec.authors = ["Achilleas Buisman"]
  spec.email = ["accounts@abuisman.nl"]

  spec.summary = "Merge Tailwind CSS classes"
  spec.description = "Merge Tailwind CSS classes"
  spec.homepage = "https://github.com/abuisman/tail_merge"
  spec.required_ruby_version = ">= 3.1.0"
  spec.required_rubygems_version = ">= 3.3.11"
  spec.license = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/abuisman/tail_merge"

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
  spec.extensions = ["ext/tail_merge/extconf.rb"]

  spec.add_dependency "rb_sys", "~> 0.9.115"
end
