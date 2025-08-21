# frozen_string_literal: true

require_relative "tail_merge/version"
require "tail_merge/merger"

# Main class for merging tailwind classes.
class TailMerge
  class Error < StandardError; end

  def self.merge(classes, options = {})
    Merger.perform(classes, options)
  end

  attr_reader :options

  def initialize(options = {})
    @options = options
    @class_hash = {}
  end

  def merge(classes)
    return "" if classes.empty?

    classes = classes.join(" ") if classes.is_a?(Array)
    @class_hash[classes] ||= Merger.perform(classes, options)
  end
end
