# frozen_string_literal: true
require_relative "base"

module Boa
  module Plugin
    class BoaYAML < Boa::Plugin::Base
      Boa::Plugin.register("yaml", self)

      def deserialize(data)
        require "yaml"
        YAML.load data
      end
    end
  end
end