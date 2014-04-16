# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/jwt/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-jwt"
  spec.version       = Rack::JWT::VERSION
  spec.authors       = ["Erwin Boskma"]
  spec.email         = ["erwin@datarift.nl"]
  spec.summary       = %q{Handles transparent decoding of JSON Web Tokens}
  spec.description   = %q{Rack::JWT is a Rack middleware to transparently decode JSON Web Tokens}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "jwt", "~> 0.1.11"
  spec.add_dependency "rack", "~> 1.5.2"
  
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test", "~> 0.6.2"
  spec.add_development_dependency "rspec", "~> 2.14.1"
end
