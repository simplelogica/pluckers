# Pluckers

[![CircleCI](https://circleci.com/gh/simplelogica/pluckers/tree/master.svg?style=svg)](https://circleci.com/gh/simplelogica/pluckers/tree/master)

Gem extending the idea behind AR's pluck method so we can fetch data from multiple tables.

## The idea

ActiveRecord is a powerful tool to create and mantain the model and persistence of a Ruby application, but just as every tool it must be used when it's really needed.

As an example, ActiveRecord objects are quite expensive to instantiate compared with simpler objects, such as arrays or hashes. In the following benchmark we can see times returned by Ruby's benchmark for some simple samples.

```
> puts Benchmark.measure { 1000.times{BlogPost.new} }
  0.030000   0.010000   0.040000 (  0.079227)
=> nil
> puts Benchmark.measure { 10000.times{BlogPost.new} }
  0.320000   0.000000   0.320000 (  0.381990)
=> nil
> puts Benchmark.measure { 100000.times{BlogPost.new} }
  3.350000   0.010000   3.360000 (  3.546527)
=> nil
```

```
> puts Benchmark.measure { 1000.times{Hash.new} }
  0.010000   0.000000   0.010000 (  0.001668)
=> nil
> puts Benchmark.measure { 10000.times{Hash.new} }
  0.020000   0.000000   0.020000 (  0.039580)
=> nil
> puts Benchmark.measure { 100000.times{Hash.new} }
  0.140000   0.020000   0.160000 (  0.228560)
=> nil
```

This is the idea behind the `pluck` method ActiveRecord includes. Use ActiveRecord to manage the persistence and connection to the database, but return simple objects such as Arrays or Hashes to manage the information in ruby, avoiding to instantiate heavier objects.

```
> 10000.times {|i| BlogPost.create(title: "Title #{i}")}

> puts Benchmark.measure { BlogPost.all.map(&:title) }
  0.560000   0.010000   0.570000 (  0.704659)
=> nil

> puts Benchmark.measure { BlogPost.pluck(:title) }
  0.110000   0.000000   0.110000 (  0.172678)
=> nil
```

Unfortunately, `pluck` method is limited to attributes from the model and lack some other features, such as navigate through relations.

This gem `pluckers` creates a new kind of objects (yes, Pluckers) that encapsulate all the logic of plucking attributes and relations in a recursive way just using the definition of our model created by ActiveRecord but instantiating just arrays and hashes, not a single ActiveRecord::Base object.

Furthermore, these objects will become a single point of access to the database that will force us to think which information we really need, avoiding long SELECT queries and ending with N+1 issues in a clean and transparent way.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pluckers'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pluckers

## USAGE

### Creating the plucker

You may use the `Pluckers::Base` class to pluck all the information you need:

```ruby
Pluckers::Base.new(Model.scope, options)
```

You can use any ActiveRecord Relation. It means you can pluck any scope or collection just as you would use them in your Rails applications:

```ruby
plucker = Pluckers::Base.new(BlogPost.published)
plucker = Pluckers::Base.new(Author.all)
plucker = Pluckers::Base.new(post.categories.published)
```

Once you have the plucker object you just... pluck.

```ruby
plucker.pluck
```

### Selecting columns

When you create the plucker you can configure some options to customize it.

First, you can choose which columns to pluck from the table, so you don't 50 columns when you only need three of them. To do so you will use the `attributes` option.

```ruby
Pluckers::Base.new(BlogPost.published, { attributes: [:title, :slug, :published_at] }).pluck
```
```ruby
[
  { id: 33, title: "Lorem Ipsum", slug: 'lorem-ipsum', published_at: "2016-04-07"},
  { id: 34, title: "Lorem Ipsum 3", slug: 'lorem-ipsum-3', published_at: "2016-04-09"},
  { id: 35, title: "Lorem Ipsum 4", slug: 'lorem-ipsum-4', published_at: "2016-04-12"}
]
```

Of course, this will be done in just one query.

### Selecting Globalized columns

If you are using Globalize you may find useful to pluck translated columns. You just have to include it in the attributes options and it will automatically recognize it as a translated column and will pluck it from that table.

```ruby
Pluckers::Base.new(post.categories.published, { attributes: [:name] }).pluck
```
```ruby
[
  { id: 2, name: "gifs" },
  { id: 34, name: "shiba" },
  { id: 35, name: "ducktales" }
]
```

In some scenarios you may need to pluck some specific language. You can do it with the `attributes_with_locale` options.

```ruby
Pluckers::Base.new(post.categories.published, { attributes_with_locale: { es: [:name] }).pluck
```
```ruby
[
  { id: 2, name_es: "gifs" },
  { id: 34, name_es: "shiba" },
  { id: 35, name_es: "patoaventuras" }
]
```

Since these are independent options you can combine them.

```ruby
Pluckers::Base.new(post.categories.published, {
  attributes: [:name],
  attributes_with_locale: { es: [:name] }
}).pluck
```
```ruby
[
  { id: 2, name: "gifs", name_es: "gifs" },
  { id: 34, name: "shiba", name_es: "shiba" },
  { id: 35, name: "ducktales", name_es: "patoaventuras" }
]
```

Pluckers will use Globalize fallback locales configuration to return the most appropiate value. I.e. If some post has no content on english locale and its fallback is spanish, it will return the value in spanish locale.

All these operations will be done in an extra query, no matter the number of locales available in Globalize.

### Renaming columns

Imagine you're plucking your spanish name to use it in Google Analytics integration so the visit is registered to the same category, no matter the language.

You may use `name_es` in your code or you could rename the attribute to a more meaningful name such as `name_for_analytics` through the `renames` option.

```ruby
Pluckers::Base.new(post.categories.published, {
  attributes: [:name],
  attributes_with_locale: { es: [:name] },
  renames: { name_es: :name_for_analytics}
}).pluck
```
```ruby
[
  { id: 2, name: "gifs", name_for_analytics: "gifs" },
  { id: 34, name: "shiba", name_for_analytics: "shiba" },
  { id: 35, name: "ducktales", name_for_analytics: "patoaventuras" }
]
```

This will require no extra database query.

### Traversing relationships

Until now you can pluck attributes. Now we introduce an option to traverse relationships in the model, so you can pluck not only one model, but any related model, through the `reflections` option.

Imagine, for the previous example, you want to pluck the post information for each category.

```ruby
Pluckers::Base.new(post.categories.published, {
  attributes: [:name],
  attributes_with_locale: { es: [:name] },
  renames: { name_es: :name_for_analytics},
  reflections: {
    posts: {
      attributes: [:title, :slug, :published_at],
    }
  }
}).pluck
```
```ruby
[
  { id: 2, name: "gifs", name_for_analytics: "gifs",
     posts: [
       { id: 33, title: "Lorem Ipsum", slug: 'lorem-ipsum', published_at: "2016-04-07"},
       { id: 32, title: "Lorem Ipsum not", slug: 'lorem-ipsum-not', published_at: nil}
     ]
  },
  { id: 34, name: "shiba", name_for_analytics: "shiba",
     posts: [
       { id: 34, title: "Lorem Ipsum 3", slug: 'lorem-ipsum-3', published_at: "2016-04-09"},
       { id: 35, title: "Lorem Ipsum 4", slug: 'lorem-ipsum-4', published_at: "2016-04-12"}
     ]
  },
  { id: 35, name: "ducktales", name_for_analytics: "patoaventuras"
     posts: [
       { id: 33, title: "Lorem Ipsum", slug: 'lorem-ipsum', published_at: "2016-04-07"}
       { id: 34, title: "Lorem Ipsum 3", slug: 'lorem-ipsum-3', published_at: "2016-04-09"},
       { id: 35, title: "Lorem Ipsum 4", slug: 'lorem-ipsum-4', published_at: "2016-04-12"}
     ]
  }
]
```

As we just use the `attributes` option for the reflection we just perform an extra database query, avoiding N+1.

Each element in the reflections options has a key and a hash of options. The key is the name of the relationship as defined in the Active Record model. The value is a hash of options that takes the exact same options that are allowed for the plucker. In fact, internally we create another plucker to retrieve the posts.

This means that we can do everything in this "secondary" plucker. We can get globalize columns, we can rename... and we can also get another related models, giving us the ability to obtain a whole tree of models and objects in just one single point, with the minimum database queries required.

As an example, imagine we want to obtain the name of the author of each one of the retrieved post.

```ruby
Pluckers::Base.new(post.categories.published, {
  attributes: [:name],
  attributes_with_locale: { es: [:name] },
  renames: { name_es: :name_for_analytics},
  reflections: {
    posts: {
      attributes: [:title, :slug, :published_at],
      reflections: {
        author: { attributes: [:name] }
      }
    }
  }
}).pluck
```
```ruby
[
  { id: 2, name: "gifs", name_for_analytics: "gifs",
     posts: [
       { id: 33, title: "Lorem Ipsum", slug: 'lorem-ipsum', published_at: "2016-04-07",
         autor: { id: 1, name: "Someone"}
       },
       { id: 32, title: "Lorem Ipsum not", slug: 'lorem-ipsum-not', published_at: nil,
         autor: { id: 2, name: "Someone else"}
       }
     ]
  },
  { id: 34, name: "shiba", name_for_analytics: "shiba",
     posts: [
       { id: 34, title: "Lorem Ipsum 3", slug: 'lorem-ipsum-3', published_at: "2016-04-09",
         autor: { id: 3, name: "Another one"}
       },
       { id: 35, title: "Lorem Ipsum 4", slug: 'lorem-ipsum-4', published_at: "2016-04-12",
         autor: { id: 1, name: "Someone"}
       }
     ]
  },
  { id: 35, name: "ducktales", name_for_analytics: "patoaventuras"
     posts: [
       { id: 33, title: "Lorem Ipsum", slug: 'lorem-ipsum', published_at: "2016-04-07",
         autor: { id: 1, name: "Someone"}
       },
       { id: 34, title: "Lorem Ipsum 3", slug: 'lorem-ipsum-3', published_at: "2016-04-09",
         autor: { id: 3, name: "Another one"}
       },
       { id: 35, title: "Lorem Ipsum 4", slug: 'lorem-ipsum-4', published_at: "2016-04-12",
         autor: { id: 1, name: "Someone"}
       }
     ]
  }
]
```

This would've been performed with 4 database queries:

  - Category attributes.
  - Category globalized attributes.
  - Related posts attributes.
  - Related authors from related posts attributes.

Sometimes may be useful to apply some restrictions on the related objects we are plucking. Maybe we don't want all the posts to be plucked, only the published ones in order to show the links.

We can restrict the related objects to be plucked through the `scope` option which accepts standard ActiveRecord scopes which will be used to build the query when plucking related objects.

```ruby
Pluckers::Base.new(post.categories.published, {
  attributes: [:name],
  attributes_with_locale: { es: [:name] },
  renames: { name_es: :name_for_analytics},
  reflections: {
    posts: {
      attributes: [:title, :slug, :published_at],
      reflections: {
        author: { attributes: [:name] }
      },
      scope: BlogPost.published
    }
  }
}).pluck
```
```ruby
[
  { id: 2, name: "gifs", name_for_analytics: "gifs",
     posts: [
       { id: 33, title: "Lorem Ipsum", slug: 'lorem-ipsum', published_at: "2016-04-07",
         autor: { id: 1, name: "Someone"}
       }
     ]
  },
  { id: 34, name: "shiba", name_for_analytics: "shiba",
     posts: [
       { id: 34, title: "Lorem Ipsum 3", slug: 'lorem-ipsum-3', published_at: "2016-04-09",
         autor: { id: 3, name: "Another one"}
       },
       { id: 35, title: "Lorem Ipsum 4", slug: 'lorem-ipsum-4', published_at: "2016-04-12",
         autor: { id: 1, name: "Someone"}
       }
     ]
  },
  { id: 35, name: "ducktales", name_for_analytics: "patoaventuras"
     posts: [
       { id: 33, title: "Lorem Ipsum", slug: 'lorem-ipsum', published_at: "2016-04-07",
         autor: { id: 1, name: "Someone"}
       },
       { id: 34, title: "Lorem Ipsum 3", slug: 'lorem-ipsum-3', published_at: "2016-04-09",
         autor: { id: 3, name: "Another one"}
       },
       { id: 35, title: "Lorem Ipsum 4", slug: 'lorem-ipsum-4', published_at: "2016-04-12",
         autor: { id: 1, name: "Someone"}
       }
     ]
  }
]
```

This would've been performed with 4 database queries:

  - Category attributes.
  - Category globalized attributes.
  - Related posts attributes filtering with the `published` scope as defined in the `BlogPost` model.
  - Related authors from related posts attributes.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/simplelogica/pluckers. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

