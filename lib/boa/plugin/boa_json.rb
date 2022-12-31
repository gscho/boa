# frozen_string_literal: true

require_relative "base"
require "json"

module Boa
  module Plugin
    class BoaJSON < Boa::Plugin::Base
      Boa::Plugin.register("json", self)

      def deserialize(data)
        JSON.parse data
      end

      def serialize(config)
        config.to_json
      end
    end
  end
end
