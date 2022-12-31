# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in Boa.gemspec
gemspec

group :development do
  gem "minitest", "~> 5.0"
  gem "rake", "~> 13.0"
  gem "rubocop", "~> 1.21"
end

group :test do
  gem "foo", path: "./test/fixtures/foo"
end
