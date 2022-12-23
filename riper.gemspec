# frozen_string_literal: true

require_relative "lib/riper/version"

Gem::Specification.new do |spec|
  spec.name = "riper"
  spec.version = Riper::VERSION
  spec.authors = ["Gregory Schofield"]
  spec.email = ["greg.c.schofield@gmail.com"]
  spec.summary = "A ruby implementation of the viper configuration library."
  spec.homepage = "https://github.com/gscho/riper"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.require_paths = ["lib"]
end
