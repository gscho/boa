# frozen_string_literal: true
require_relative "base"

module Riper
  module Plugin
    class RiperYAML < Riper::Plugin::Base
      Riper::Plugin.register("yaml", self)

      def deserialize(data)
        require "yaml"
        YAML.load data
      end
    end
  end
end