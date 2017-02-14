# Renaming columns

PREVIOUSLY: [How to use your plucker with your globalized methods](./globalize.md)

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

NEXT: [How to use your plucker for traversing through relationships and obtain data from several tables without N+1 and with the minimum queries](./relationships.md)
