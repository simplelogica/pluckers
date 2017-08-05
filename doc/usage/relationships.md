# Traversing relationships

PREVIOUSLY: [How to rename your fetched attributes](./renaming.md)

Until now you can pluck attributes. Now we introduce an option to traverse relationships in the model, so you can pluck not only one model, but any related model, through the `reflections` option.

## Fetching relationships

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

## Foreign keys and minimum data plucked

Although in the examples we only show ids involved, relationships configured with different foreign keys can be fetched too as the configuration is read by the plucker to use the proper columns in both involved tables.

In order to be able to relate the plucked data all the foreign keys must be plucked, that's why in the previous example all the posts plucked their `id` although in the `attributes` option we specied only `[:title, :slug, :published_at]`.

## Fetching only ids

For `has_many` and `has_and_belongs_to_many` relationships you could be interested in only fetching the ids of the related objects. You can get this by using the `only_ids` option in the relationship to fetch.

```ruby
Pluckers::Base.new(post.categories.published, {
  attributes: [:name],
  attributes_with_locale: { es: [:name] },
  renames: { name_es: :name_for_analytics},
  reflections: {
    posts: { only_ids: true }
  }
}).pluck
```

```ruby
[
  { id: 2, name: "gifs", name_for_analytics: "gifs",
     post_ids: [33, 32]
  },
  { id: 34, name: "shiba", name_for_analytics: "shiba",
     posts_ids: [34, 35]
  },
  { id: 35, name: "ducktales", name_for_analytics: "patoaventuras"
     post_ids: [33, 34, 35]
  }
]
```

## Traversing relationships in a recursive way

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

## Applying scopes

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

NEXT: [How to create your own plucker classes to encapsulate all your plucking options and logic](./extending.md)
