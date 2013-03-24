# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cloud/agent'

Gem::Specification.new do |s|
  s.name          = 'cloud-agent'
  s.version       = Cloud::Agent::VERSION
  s.authors       = ['George Drummond']
  s.email         = ['georgedrummond@gmail.com']
  s.description   = %q{Cloud deploy agent}
  s.summary       = %q{Cloud deploy agent}
  s.homepage      = 'https://github.com/georgedrummond'
  s.license       = 'MIT'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_dependency 'rest-client'
  s.add_dependency 'grape'
  s.add_dependency 'json'

  s.add_development_dependency 'bundler', '~> 1.3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'minitest-colorize'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'rr'
end
