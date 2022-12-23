require "riper/plugin/base"

module Riper
  module Plugin
    class RiperFoo < Riper::Plugin::Base
      Riper::Plugin.register("foo", self)
      
      def deserialize(data)
        {
          "foo" => "bar"
        }
      end
    end
  end
end