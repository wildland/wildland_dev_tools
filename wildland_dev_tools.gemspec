# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wildland_dev_tools/version'

Gem::Specification.new do |spec|
  spec.name          = "wildland_dev_tools"
  spec.version       = WildlandDevTools::VERSION
  spec.authors       = ["Joe Weakley"]
  spec.email         = ["joe@wild.land.com"]

  spec.summary       = 'Wildland Dev Tools'
  spec.description   = 'Wildland Dev Tools'
  spec.homepage      = 'http://wild.land'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency 'rails', ['>= 4.1']
  spec.add_runtime_dependency 'git', '~> 1.3', '>= 1.3.0'
  spec.add_runtime_dependency 'highline', '~> 1.7'
  spec.add_runtime_dependency 'rubocop', '~> 0.66.0'
  spec.add_runtime_dependency 'reek', '~> 5.3'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec', '~> 0'
end
