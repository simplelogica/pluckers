# Pluckers

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/simplelogica/pluckers. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

