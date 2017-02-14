# Creating the plucker and fething basic data

## Creating the plucker

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

## Selecting columns

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

NEXT: [How to use your plucker with your globalized methods](./globalize.md)
