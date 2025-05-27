# TailMerge

TailMerge is a super fast utility library to merge Tailwind CSS classes without conflicts.

```ruby
TailMerge.merge %w[px-2 py-1 bg-red hover:bg-dark-red p-3 bg-[#B91C1C]]
=> "hover:bg-dark-red p-3 bg-[#B91C1C]"
```

Classes on the right will override classes on the left.

TailMerge wraps the Rust library [rustui_merge](https://docs.rs/rustui_merge/latest/rustui_merge/) so that it can be used in Ruby. This makes it a lot faster than combining classes in Ruby.

## Purpose

When you use Tailwindcss to style components, you will probably run into the situation where you want to adjust the styling of component in a specific situation.

An example:

```ruby
class Well < ApplicationComponent
  def initialize(**options)
    @classes = options.delete(:classes)
  end

  def call
    tag.div class: default_classes + @classes
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
    tag.div class: TailMerge.merge(default_classes + @classes)
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

You can pass a string or an array of strings to the `merge` method.

Whatever you pass last will override whatever you pass first.

A string is returned for easy use in ERB.

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

This caching technique was inspired by [[Tailwind Merge](https://github.com/dcastil/tailwind-merge)](https://github.com/gjtorikian/tailwind_merge).

## Benchmark

So how fast/much faster is TailMerge?

I've benchmarked TailMerge with an instance (cached) and without an instance against Tailwind Merge with (cached) and without a merger instance, and these are the results:

```
                                                  user     system      total        real
Rust: TailMerge.merge (all samples):          0.216178   0.001744   0.217922 (  0.219441)
Rust: Cached TailMerge.merge (all samples):   0.005465   0.000092   0.005557 (  0.005581)
Ruby: TailwindMerge each time (all samples): 50.391383   0.494058  50.885441 ( 52.272354)
Ruby:Cached TailwindMerge (all samples):      0.011672   0.000140   0.011812 (  0.011813)
```

As you can see TailMerge is much faster using pure Ruby to merge classes.

The benchmark loops through an array of strings and arrays and merges them 1000 times.

The difference between the cached runs, obviously, is much smaller as we are basically benchmarking the cache lookup and not the actual merge.

In reality we will not deal with 1000 merges to be done per page and I suspect you'd be much closer to the non-cached runs.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/abuisman/tail_merge . Merging will be done at my own pace and discretion.
