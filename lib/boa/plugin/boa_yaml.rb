# frozen_string_literal: true
require_relative "base"
require "yaml"

module Boa
  module Plugin
    class BoaYAML < Boa::Plugin::Base
      Boa::Plugin.register("yaml", self)

      def deserialize(data)
        YAML.load data
      end

      def serialize(config)
        config.to_yaml
      end
    end
  end
end