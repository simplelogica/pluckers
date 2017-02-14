# Pluckers

[![CircleCI](https://circleci.com/gh/simplelogica/pluckers/tree/master.svg?style=svg)](https://circleci.com/gh/simplelogica/pluckers/tree/master)

This gem extends the idea behind AR's pluck method so we can fetch data from multiple tables and create our own classes to encapsulate how we fetch data from the database and which bussines logic may be applied to them. You can read more about [The Idea](./doc/idea.md).

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

In this section you will learn

* [How to use a plucker and what do you obtain from it](./doc/usage/basics.md)
* [How to use your plucker with your globalized methods](./doc/usage/globalize.md)
* [How to rename your fetched attributes](./doc/usage/renaming.md)
* [How to use your plucker for traversing through relationships and obtain data from several tables without N+1 and with the minimum queries](./doc/usage/relationships.md)
* [How to create your own plucker classes to encapsulate all your plucking options and logic](./doc/usage/relationships.md)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/simplelogica/pluckers. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

