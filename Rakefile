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

# Cross-compile for every Ruby in the rake-compiler-dock image that the gemspec supports
require "rake_compiler_dock"
ENV["RUBY_CC_VERSION"] ||= RakeCompilerDock.ruby_cc_version(GEMSPEC.required_ruby_version.to_s)

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
  ext.cross_platform = %w[x86-mingw32 x64-mingw-ucrt x64-mingw32 x86-linux x86_64-linux aarch64-linux x86_64-darwin arm64-darwin]
end

desc "Build native extension for a given platform (i.e. `rake 'native[x86_64-linux]'`)"
task :native, [:platform] do |_t, platform:|
  raise ArgumentError, "platform is required, e.g. rake 'native[x86_64-linux]'" if platform.nil? || platform.empty?

  sh "bundle", "exec", "rb-sys-dock", "--platform", platform, "--build"
end

task default: %i[compile test rubocop]
