lib = File.expand_path("../lib", __FILE__)
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
  spec.files       = ["lib/**/*.rb"]
  spec.homepage    = 'http://github.com/jdee/pattern_patch'
  spec.license     = 'MIT'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec-simplecov'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
end
