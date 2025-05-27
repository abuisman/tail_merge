# TailMerge

TailMerge is a super-fast utility library to merge Tailwind CSS classes without conflicts.

```ruby
TailMerge.merge %w[px-2 py-1 bg-red hover:bg-dark-red p-3 bg-[#B91C1C]]
=> "hover:bg-dark-red p-3 bg-[#B91C1C]"
```

Classes that appear later in the list override earlier ones.

By leveraging the Rust crate [rustui_merge](https://docs.rs/rustui_merge/latest/rustui_merge/), TailMerge merges classes significantly faster than pure Ruby alternatives.

## Purpose

When you use Tailwind CSS to style components, you'll often want to adjust the styling of a component in certain situations.

An example:

```ruby
class Well < ApplicationComponent
  def initialize(**options)
    @classes = options.delete(:classes)
  end

  def call
    tag.div class: default_classes + @classes do
      content
    end
  end

  def default_classes
    %w[bg-gray-100 rounded-lg p-4]
  end
end
```

If you want to render this component somewhere with a different background, ideally you'd be able to do this:

```erb
<%= render Well.new(classes: %w[bg-blue-50 p-2]) do %>
  <p>Hello</p>
<% end %>
```

Sadly, this will not work. The div will have a gray-100 background and a padding of 4 instead of the intended blue-50 and p-2.

This is where TailMerge comes in. It allows you to merge classes without conflicts.

```ruby
TailMerge.merge %w[bg-gray-100 rounded-lg p-4] + %w[bg-blue-50 p-2]
=> "rounded-lg bg-blue-50 p-2"
```

Implementing this in your component is easy:

```ruby
class Well < ApplicationComponent
  def initialize(**options)
    @classes = options.delete(:classes)
  end

  def call
    tag.div class: TailMerge.merge(default_classes + @classes) do
      content
    end
  end

  def default_classes
    %w[bg-gray-100 rounded-lg p-4]
  end
end
```

No more conflicts!

## Installation

Add the gem to your Gemfile:

```ruby
gem "tail_merge"
```

Run `bundle install` to install the gem.

## Usage

You can pass either a string or an array of strings to the merge method. Values passed later override previous ones. The result is always a string, ready for use in ERB templates.

```ruby
TailMerge.merge %w[px-2 py-1 bg-red hover:bg-dark-red p-3 bg-[#B91C1C]]
=> "hover:bg-dark-red p-3 bg-[#B91C1C]"
```

```ruby
TailMerge.merge "px-2 py-1 bg-red hover:bg-dark-red p-3 bg-[#B91C1C]"
=> "hover:bg-dark-red p-3 bg-[#B91C1C]"
```

## More speed?

You can create an instance of TailMerge and call `merge` on it instead of on the `TailMerge` class. This will cache the results of the merge.

This is useful in cases where you need to merge the same classes repeatedly, such as when rendering a list of the same component.

```ruby
tail_merge_instance = TailMerge.new
tail_merge_instance.merge %w[px-2 py-1 bg-red hover:bg-dark-red p-3 bg-[#B91C1C]]
=> "hover:bg-dark-red p-3 bg-[#B91C1C]" # Write to cache, still fast though

# Second time, same key, read from cache
tail_merge_instance.merge %w[px-2 py-1 bg-red hover:bg-dark-red p-3 bg-[#B91C1C]]
=> "hover:bg-dark-red p-3 bg-[#B91C1C]" # Read from cache, much faster!

# Third time, string key instead of array, read from same cache
tail_merge_instance.merge "px-2 py-1 bg-red hover:bg-dark-red p-3 bg-[#B91C1C]"
=> "hover:bg-dark-red p-3 bg-[#B91C1C]" # Read from cache, much faster!
```

This caching technique was inspired by [Tailwind Merge](https://github.com/dcastil/tailwind-merge).

## Benchmark

So how fast is TailMerge?

I've benchmarked TailMerge with and without caching, and compared it to Tailwind Merge (also with and without caching). Here are the results:

```
                                                  user     system      total        real
Rust: TailMerge.merge (all samples):          0.371744   0.019642   0.391386 (  0.391821)
Rust: Cached TailMerge.merge (all samples):   0.012976   0.000580   0.013556 (  0.013560)
Ruby: TailwindMerge each time (all samples): 51.488919   0.225130  51.714049 ( 51.883713)
Ruby:Cached TailwindMerge (all samples):      0.019882   0.000166   0.020048 (  0.020051)
```

As you can see, TailMerge is much faster than using pure Ruby to merge classes.

The benchmark loops through an array of strings and arrays and merges them 1000 times.

The difference between the cached runs, obviously, is much smaller as we are basically benchmarking the cache lookup and not the actual merge.

In reality, you will not need to perform 1000 merges per page, and I suspect you'll be much closer to the non-cached runs.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/abuisman/tail_merge . Merging will be done at my own pace and discretion.

## License

This gem is available as open source under under the MIT License.
