require_relative '../simplecov_custom_profiles'
SimpleCov.start 'msfl-visitors'
require 'rspec/support/spec'
require 'byebug'
require 'msfl_visitors'
# require the test datasets from the msfl gem
require 'msfl/datasets/car'
require 'msfl/datasets/movie'
require 'msfl/datasets/person'