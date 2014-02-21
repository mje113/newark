# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'newark/version'

Gem::Specification.new do |spec|
  spec.name          = 'newark'
  spec.version       = Newark::VERSION
  spec.authors       = ['Mike Evans']
  spec.email         = ['mike@urlgonomics.com']
  spec.summary       = %q{Pico Web Framework}
  spec.description   = %q{Because everyone should write their own framework.}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'rack', '>= 1.5.2'
  spec.add_dependency 'activesupport'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'benchmark-ips'
end
