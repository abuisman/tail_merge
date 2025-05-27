# frozen_string_literal: true

require_relative "tail_merge/version"
require_relative "tail_merge/merger"

class TailMerge
  class Error < StandardError; end

  Merger = ::Merger

  def self.merge(classes, options = {})
    TailMerge::Merger.perform(classes, options)
  end
end
