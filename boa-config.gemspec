# frozen_string_literal: true

require_relative "lib/boa/version"

Gem::Specification.new do |spec|
  spec.name = "boa-config"
  spec.version = Boa::VERSION
  spec.authors = ["Gregory Schofield"]
  spec.email = ["greg.c.schofield@gmail.com"]
  spec.summary = "A configuration library inspired by spf13/viper."
  spec.homepage = "https://github.com/gscho/boa"
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
  spec.metadata["rubygems_mfa_required"] = "true"
end
