$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
require 'rspec/simplecov'

require 'pattern_patch'

SimpleCov.minimum_coverage 95
SimpleCov.start
