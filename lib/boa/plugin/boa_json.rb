# frozen_string_literal: true
require_relative "base"

module Boa
  module Plugin
    class BoaJSON < Boa::Plugin::Base
      Boa::Plugin.register("json", self)

      def deserialize(data)
        require "json"
        JSON.parse data
      end
    end
  end
end