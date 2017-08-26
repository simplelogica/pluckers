require 'bundler/setup'
require 'active_record'
require 'pluckers'
require_relative '../dummy/dummy'
require_relative 'support'

author_attributes = {
  name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  email: "foobar@email.com"
}

post_attributes =       {
  title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
}

1000.times do
  author = Author.create!(author_attributes)
  10.times do
    author.blog_posts.create!(post_attributes)
  end
end

Benchmark.run("activerecord/includes", time: 5) do
  str = ""
  Author.includes(:blog_posts).all.each do |author|
    str << "name: #{author.name} email: #{author.email}\n"
    author.blog_posts.each do |post|
      str << "title: #{post.title} text: #{post.text}\n"
    end
  end
end
