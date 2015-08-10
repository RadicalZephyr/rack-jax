# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack_jax/version'

Gem::Specification.new do |spec|
  spec.name          = "rack_jax"
  spec.version       = RackJax::VERSION
  spec.authors       = ["Zefira Shannon"]
  spec.email         = ["geoffpshannon@gmail.com"]
  spec.summary       = %q{A rack interface to my http server.}
  spec.description   = %q{Allows the usage of all standard Rack development tools. Ideally, an already working Rack app can be just plugged into rack jax and "Just Work".}
  spec.homepage      = "https://github.com/RadicalZephyr/rack-jax"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "3.2.0"

end
