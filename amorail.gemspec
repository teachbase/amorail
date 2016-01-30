# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'amorail/version'

Gem::Specification.new do |spec|
  spec.name          = "amorail"
  spec.version       = Amorail::VERSION
  spec.authors       = ["alekseenkoss", "palkan"]
  spec.email         = ["alekseenkoss@gmail.com", "dementiev.vm@gmail.com"]
  spec.summary       = %q{Ruby API client for AmoCRM}
  spec.description   = %q{Ruby API client for AmoCRM. You can integrate your system with it.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'shoulda-matchers', "~> 2.0"
  spec.add_dependency "anyway_config", "~> 0", ">= 0.3"
  spec.add_dependency "faraday"
  spec.add_dependency "faraday_middleware"
  spec.add_dependency 'activemodel'
  spec.add_dependency 'json'
end
