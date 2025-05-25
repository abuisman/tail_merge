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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/abuisman/tail_merge.
