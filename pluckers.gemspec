# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pluckers/version'

Gem::Specification.new do |spec|
  spec.name          = "pluckers"
  spec.version       = Pluckers::VERSION
  spec.authors       = ["David J. Brenes"]
  spec.email         = ["gems@simplelogica.net"]
  spec.license       = 'GPL-3.0'

  spec.summary       = %q{Gem extending the idea behind AR's pluck method so we can fetch data from multiple tables}
  spec.description   = %q{Gem extending the idea behind AR's pluck method so we can fetch data from multiple tables}
  spec.homepage      = "https://github.com/simplelogica/pluckers"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(bin|gemfiles|test)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", "> 3.2", "< 5.1"

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "globalize"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "appraisal", "~> 2.1.0"
end
