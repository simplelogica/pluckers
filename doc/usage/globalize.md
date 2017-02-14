# Selecting Globalized columns

PREVIOUSLY: [How to use a plucker and what do you obtain from it](./basics.md)

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
## Selecting a specific locale

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

## Fallback translations

Pluckers will use Globalize fallback locales configuration to return the most appropiate value. I.e. If some post has no content on english locale and its fallback is spanish, it will return the value in spanish locale.

All these operations will be done in an extra query, no matter the number of locales available in Globalize.

NEXT: [How to rename your fetched attributes](./renaming.md)
