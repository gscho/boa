# frozen_string_literal: true

require_relative "riper/plugin"
require_relative "riper/config"
require_relative "riper/version"

module Riper
  class RiperPluginError < StandardError; end
end

$riper = Riper::Config.instance
