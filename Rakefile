# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

begin
  require "rubocop/rake_task"
  RuboCop::RakeTask.new
rescue LoadError
  # RuboCop is an optional dev dependency; skip in minimal build environments
end

require "rb_sys/extensiontask"

task build: :compile

GEMSPEC = Gem::Specification.load("tail_merge.gemspec")

# Limit cross-compiled Ruby versions to those supported by this gem and dependencies
# Format matches rake-compiler's RUBY_CC_VERSION (colon-separated list)
ENV["RUBY_CC_VERSION"] ||= "3.1.6:3.2.6:3.3.7:3.4.1"

PLATFORMS = %w[
  aarch64-linux-gnu
  aarch64-linux-musl
  arm-linux-gnu
  arm-linux-musl
  arm64-darwin
  x64-mingw-ucrt
  x64-mingw32
  x86-linux-gnu
  x86-linux-musl
  x86-mingw32
  x86_64-darwin
  x86_64-linux-gnu
  x86_64-linux-musl
].freeze

RbSys::ExtensionTask.new("merger", GEMSPEC) do |ext|
  ext.lib_dir = "lib/tail_merge"
  ext.cross_compile = true
  ext.cross_platform = %w[x86-mingw32 x64-mingw-ucrt x64-mingw32 x86-linux x86_64-linux x86_64-darwin arm64-darwin]
end

desc "Build native extension for a given platform (i.e. `rake 'native[x86_64-linux]'`)"
task :native, [:platform] do |_t, platform:|
  raise ArgumentError, "platform is required, e.g. rake 'native[x86_64-linux]'" if platform.nil? || platform.empty?

  if platform.end_with?("-darwin")
    # On macOS runners, prefer the native rake task (no Docker available)
    sh "bundle", "exec", "rake", "native:#{platform}", "gem"
  else
    # For Linux/Windows, use Docker-based cross compilation
    sh "bundle", "exec", "rb-sys-dock", "--platform", platform, "--build"
  end
end

task default: %i[compile test rubocop]
