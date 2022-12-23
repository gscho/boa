# frozen_string_literal: true
require_relative "base"

module Riper
  module Plugin
    class RiperJSON < Riper::Plugin::Base
      Riper::Plugin.register("json", self)

      def deserialize(data)
        require "json"
        JSON.parse data
      end
    end
  end
end