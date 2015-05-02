require 'simplecov'
SimpleCov.profiles.define 'msfl-visitors' do
  add_filter '/spec'
  add_filter '/test'
end