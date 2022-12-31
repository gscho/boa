# frozen_string_literal: true

require "sinatra"
require_relative "config"

get "/foo" do
  "foo is set to #{$boa.get("foo")}"
end
