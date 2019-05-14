$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'simplecov'
require 'rspec/simplecov'

SimpleCov.minimum_coverage 95
SimpleCov.start

require 'pattern_patch'
