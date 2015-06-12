# Lesmok

Liquid ExtentionS for MOre Komfort

## Liquid markup language

Read about Liquid at:

- http://liquidmarkup.org/
- https://github.com/Shopify/liquid

# Using Lesmok

## Drop the Base...

Make any class "meltable" quickly:

```ruby
class FilmFanatic::Movie
  include ::Lesmok::Acid::Meltable
end
```

... and you can start using it in your Liquid templates immediately.

NOTE: All methods are now delegated (ACID - All Content Is Delegated),
so you don't want to do this if your liquid templates are "untrustworthy"
or your object has potentially destructive methods.

## Control the Beat...

The `Lesmok::Acid::Drop` liquid-drop class is used by default unless you:

- specify a `to_liquid` method explicitly in your class,
- override `liquify_drop_klass` to return your preferred sub-class of `Liquid::Drop`,
- or create an adjacent `*Drop` class with same naming as your model class.

```ruby
class FilmFanatic::MovieDrop < ::Lesmok::Acid::Drop    # Quick-n-dirty start.
  alias :movie :source_object                          # For readability.
  def rave                                             # Start adding presenter methods you need.
    "OMG! #{movie.title} is so awesome!"
  end
end
```

As you clean up, you may want to have more explicit drop control and migrate away from using Acid Drop:

```ruby
class FilmFanatic::MovieDrop < ::Liquid::Drop
  include ::Lesmok::Acid::Droppable        # To keep compatible with Acid::Drop
  alias :movie :source_object
end
```


## Keep your cache

Given that your object has a cache key, you can use the `cached_include` tag in your liquid templates:

```ruby
class FilmFanatic::Movie
  include ::Lesmok::Acid::Meltable
  def cache_key
    "fantastic-movie-#{self.imdb_id}"
  end
end
```

Then from your template:

```liquid
{% cached_include 'my/movie/reviews/liquid/template' for { cache_on: fantastic_movie } %}
```


# Installation

## Get tha gem...

Add this line to your application's Gemfile:

    gem 'lesmok'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lesmok


## Initialization and configuration


```ruby
Lesmok.configure do |conf|
  conf.logger = Rails.logger
  conf.available_cache_stores = {
    default: Rails.cache,
    redis:   $redis        # Using Redis is entirely optional.
  }
  conf.debugging_enabled   =  Rails.env.development?
  conf.caching_enabled     =  proc { Rails.env.production? }
  conf.raise_errors_enabled = Rails.env.development?
end
Lesmok::Liquid::Tags.register_tags
```



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
