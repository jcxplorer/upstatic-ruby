# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'upstatic/version'

Gem::Specification.new do |spec|
  spec.name          = "upstatic"
  spec.version       = Upstatic::VERSION
  spec.authors       = ["Joao Carlos"]
  spec.email         = ["mail@joao-carlos.com"]
  spec.description   = %q{Upstatic lets you deploy your static sites on AWS}
  spec.summary       = %q{Deploy static sites}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"

  spec.add_dependency "aws-sdk"
  spec.add_dependency "thor"
  spec.add_dependency "mime-types"
end
