# frozen_string_literal: true

require "boa/plugin/base"

module Boa
  module Plugin
    class BoaFoo < Boa::Plugin::Base
      Boa::Plugin.register("foo", self)

      def deserialize(_data)
        {
          "foo" => "bar"
        }
      end
    end
  end
end
