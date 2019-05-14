lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pattern_patch/version"

Gem::Specification.new do |spec|
  spec.name        = 'pattern_patch'
  spec.version     = PatternPatch::VERSION
  spec.summary     = "Apply and revert pattern-based patches to text files of any kind"
  spec.description = "This is a utility gem that identifies positions in any text using regular expressions " \
                       "and then inserts patch text at the specified location or replaces matching text. " \
                       "Many patches can be reverted."
  spec.authors     = ["Jimmy Dee"]
  spec.email       = 'jgvdthree@gmail.com'
  spec.files       = Dir["lib/**/*.rb"]
  spec.homepage    = 'http://github.com/jdee/pattern_patch'
  spec.license     = 'MIT'

  # This is necessary to support the system Ruby (2.3.3/2.3.7) on OS X High
  # Sierra & Mojave.
  spec.required_ruby_version = '>= 2.3.0'

  # Coexist with cocoapods, which requires ~> 4.0.2.
  spec.add_dependency 'activesupport', ['>= 4.0.2', '< 6']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-simplecov'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'rubocop', '0.65.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'yard'
end
