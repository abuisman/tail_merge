# frozen_string_literal: true

require "benchmark"
require "tailwind_merge"

require "bundler/setup"
require "tail_merge"

samples = [
  ["relative"],
  ["self-center"],
  ["self-start"],
  ["shadow-inner", "size-4", "text-xs"],
  ["shadow-inner", "size-7"],
  ["size-10"],
  ["static"],
  ["upload-attachment", "flex-none", "rounded-3xl", "min-h-16", "group", "relative"],
  ["w-full", "py-2", "px-2", "rounded-md", "w-44"],
  "relative",
  "self-center",
  "self-start",
  "shadow-inner size-4 text-xs",
  "shadow-inner size-7",
  "size-10",
  "static",
  "upload-attachment flex-none rounded-3xl min-h-16 group relative",
  "w-full py-2 px-2 rounded-md w-44",
  ["p-4", "px-2", "py-6", "m-3", "mx-8", "my-2", "bg-blue-500", "bg-red-600", "text-sm", "text-lg", "font-bold", "font-normal", "rounded-lg", "rounded-xl", "shadow-md", "shadow-lg", "hover:bg-blue-700", "hover:bg-red-800", "focus:ring-2", "focus:ring-4"],
  ["grid", "flex", "inline-flex", "grid-cols-3", "grid-cols-4", "gap-2", "gap-4", "items-center", "items-start", "justify-between", "justify-center", "p-8", "p-4", "bg-gray-100", "bg-white", "border", "border-2", "rounded-full", "rounded-md"],
  ["transform", "scale-100", "scale-110", "rotate-45", "rotate-90", "translate-x-2", "translate-x-4", "skew-y-3", "skew-y-6", "transition", "duration-200", "duration-500", "ease-in", "ease-out", "delay-150", "delay-300"],
  ["w-full", "w-1/2", "w-3/4", "h-screen", "h-full", "h-32", "min-h-0", "min-h-full", "max-w-xs", "max-w-xl", "overflow-hidden", "overflow-scroll", "object-cover", "object-contain", "opacity-75", "opacity-100"],
  ["text-left", "text-center", "text-right", "text-justify", "tracking-wide", "tracking-wider", "leading-tight", "leading-loose", "uppercase", "lowercase", "capitalize", "normal-case", "truncate", "line-clamp-2", "line-clamp-3"],
  ["border-t", "border-b", "border-l", "border-r", "border-solid", "border-dashed", "border-red-500", "border-blue-600", "divide-y", "divide-x", "divide-gray-200", "divide-blue-300", "ring-2", "ring-4", "ring-offset-2"],
  ["cursor-pointer", "cursor-wait", "select-none", "select-text", "resize", "resize-none", "z-10", "z-50", "float-left", "float-right", "clear-both", "clear-none", "box-border", "box-content"],
  ["bg-opacity-50", "bg-opacity-75", "backdrop-blur-sm", "backdrop-blur-lg", "backdrop-filter", "filter", "brightness-90", "brightness-110", "contrast-75", "contrast-125", "saturate-50", "saturate-200"],
  ["focus:outline-none", "focus:ring-2", "focus:ring-offset-2", "focus:border-blue-500", "hover:scale-105", "hover:rotate-3", "active:scale-95", "disabled:opacity-50", "disabled:cursor-not-allowed"],
  ["sm:text-lg", "md:text-xl", "lg:text-2xl", "xl:text-3xl", "2xl:text-4xl", "sm:w-1/2", "md:w-2/3", "lg:w-3/4", "xl:w-full", "2xl:max-w-screen-xl", "sm:p-4", "md:p-6", "lg:p-8", "xl:p-10"],
  ["dark:bg-gray-800", "dark:text-white", "dark:border-gray-600", "dark:hover:bg-gray-700", "dark:focus:ring-blue-800", "bg-white", "text-black", "border-gray-200", "hover:bg-gray-100"],
  ["group-hover:scale-110", "group-hover:rotate-6", "group-focus:outline-none", "group-active:scale-95", "peer-checked:bg-blue-500", "peer-checked:text-white", "peer-disabled:opacity-50"],
  ["animate-spin", "animate-pulse", "animate-bounce", "animate-ping", "motion-safe:animate-spin", "motion-reduce:animate-none", "transition-all", "duration-300", "ease-in-out", "delay-150"],
  ["space-x-4", "space-x-reverse", "space-y-6", "space-y-reverse", "gap-x-4", "gap-y-6", "place-items-center", "place-content-center", "place-self-center", "content-center"],
  ["from-blue-500", "to-purple-500", "via-pink-500", "bg-gradient-to-r", "bg-gradient-to-br", "text-transparent", "bg-clip-text", "bg-origin-border", "bg-no-repeat", "bg-cover"],
  ["columns-2", "columns-3", "break-inside-avoid", "break-after-column", "aspect-square", "aspect-video", "object-right-top", "object-left-bottom", "isolation-auto", "mix-blend-multiply"],
  ["first:pt-0", "last:pb-0", "odd:bg-gray-50", "even:bg-white", "first-letter:text-7xl", "first-line:uppercase", "selection:bg-yellow-200", "selection:text-black"],
  ["[mask-type:luminance]", "[mask-type:alpha]", "[transform-style:preserve-3d]", "[clip-path:circle(50%)]", "[-webkit-text-stroke:2px]", "[text-align-last:justify]"],
  ["will-change-scroll", "will-change-transform", "scroll-smooth", "scroll-mt-2", "scroll-pb-4", "overscroll-contain", "touch-pan-right", "touch-manipulation"],
  ["hyphens-auto", "hyphens-manual", "text-underline-offset-2", "text-decoration-thickness-2", "indent-8", "indent-16", "vertical-align-sub", "vertical-align-super"]
]

require 'benchmark'
require 'tail_merge'
require 'tailwind_merge'

# Pre-initialize cached mergers
cached_merger = TailwindMerge::Merger.new

tail_merge_instance = TailMerge.new

puts "Benchmarking class merging strategies (whole set)..."
puts "-" * 50
puts

Benchmark.bm(30) do |x|
  x.report("Rust: TailMerge.merge (all samples):") do
    1000.times do
      samples.each do |classes|
        TailMerge.merge(classes)
      end
    end
  end

  x.report("Rust: Cached TailMerge.merge (all samples):") do
    1000.times do
      samples.each do |classes|
        tail_merge_instance.merge(classes)
      end
    end
  end

  x.report("Ruby: TailwindMerge each time (all samples):") do
    1000.times do
      samples.each do |classes|
        TailwindMerge::Merger.new.merge(classes)
      end
    end
  end

  x.report("Ruby:Cached TailwindMerge (all samples):") do
    1000.times do
      samples.each do |classes|
        cached_merger.merge(classes)
      end
    end
  end
end
