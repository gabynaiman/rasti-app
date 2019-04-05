# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rasti/app/version'

Gem::Specification.new do |spec|
  spec.name          = 'rasti-app'
  spec.version       = Rasti::App::VERSION
  spec.authors       = ['Gabriel Naiman']
  spec.email         = ['gabynaiman@gmail.com']
  spec.summary       = ''
  spec.description   = ''
  spec.homepage      = 'https://github.com/gabynaiman/rasti-app'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'inflecto', '~> 0.0'
  spec.add_runtime_dependency 'asynchronic', '~> 1.6', '>= 1.6.3'
  spec.add_runtime_dependency 'multi_require', '~> 1.0'
  spec.add_runtime_dependency 'hash_ext', '~> 0.5'
  spec.add_runtime_dependency 'consty', '~> 1.0'
  spec.add_runtime_dependency 'rasti-form', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 11.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-colorin', '~> 0.1'
  spec.add_development_dependency 'minitest-line', '~> 0.6'
  spec.add_development_dependency 'simplecov', '~> 0.12'
  spec.add_development_dependency 'coveralls', '~> 0.8'
  spec.add_development_dependency 'pry-nav', '~> 0.2'

  if RUBY_VERSION < '2'
    spec.add_development_dependency 'term-ansicolor', '~> 1.3.0'
    spec.add_development_dependency 'tins', '~> 1.6.0'
    spec.add_development_dependency 'json', '~> 1.8'
  end
end
