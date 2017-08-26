require 'bundler/setup'
require 'active_record'
require 'pluckers'
require_relative '../dummy/dummy'
require_relative 'support'

attributes = {
  name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  email: "foobar@email.com"
}

1000.times do
  Author.create!(attributes)
end

Benchmark.run("pluckers/all", time: 5) do
  str = ""
  Pluckers::Base.new(Author.send(all_method), attributes: [:name, :email]).pluck.each do |author|
    str << "name: #{author[:name]} email: #{author[:email]}\n"
  end
end
