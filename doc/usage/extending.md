# Extending pluckers

PREVIOUSLY: [How to use your plucker for traversing through relationships and obtain data from several tables without N+1 and with the minimum queries](./relationships.md)

In some cases you may have a plucker configuration you use in several places in your application, or complex enough to extract it from the controller and isolate it so it can be easily debugged or even tested in some unit test.

You can achieve this by creating your own plucker classes that initialize the right options and delegate the complex stuff to its base class.

## Initializing options

As an example, imagine we want a plucker so we can show in a menu all the categories of our blog. We could use the base plucker as before:

```ruby
Pluckers::Base.new(Category.published, {
  attributes: [:name],
  attributes_with_locale: { es: [:name] }
}).pluck
```

Or we could have a new class:

```ruby
class CategoryMenuPlucker < Pluckers::Base

  def initialize

    super(Category.published, {
      attributes: [:name],
      attributes_with_locale: { es: [:name] }
    })

  end
end
```

And just a simple pluck call in our controller:

```ruby
CategoryMenuPlucker.new.pluck
```

We could even allow an options argument in the new class so we can customize it in different invocations.

```ruby

class CategoryMenuPlucker < Pluckers::Base

  def initialize options = {}

    options[:attributes] ||= []
    options[:attributes] << :name

    options[:attributes_with_locale] ||= {}
    options[:attributes_with_locale][:es] ||= []
    options[:attributes_with_locale][:es] << :name


    super(Category.published, options)

  end
end
```

```ruby
CategoryMenuPlucker.new.pluck
CategoryMenuPlucker.new({renames: { name_es: :name_for_analytics}}).pluck
```

## Customizing the plucked results

In this extended plucker we could even add some logic after all the results are plucked. Imagine we only want those categories with published posts. We could do the following:

```ruby

class CategoryMenuPlucker < Pluckers::Base

  def initialize options = {}

    options[:attributes] ||= []
    options[:attributes] << :name

    options[:attributes_with_locale] ||= {}
    options[:attributes_with_locale][:es] ||= []
    options[:attributes_with_locale][:es] << :name


    options[:reflections] ||= {}
    options[:reflections][:posts] = {
      attributes: [:id],
    }

    super(Category.published, options)

  end

  def pluck
    results = super

    results.select do |category|
      category[:posts].count > 0
    end
  end

end
```

This way, when we execute `CategoryMenuPlucker.new.pluck` we are plucking the categories and discarding those that don't meet our expectations.

And more important, this logic is encapsulated in the class responsible for fetching the data from the database, isolated from the controller and easily testeable.
