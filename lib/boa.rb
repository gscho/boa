# frozen_string_literal: true

require_relative "boa/plugin"
require_relative "boa/config"
require_relative "boa/version"

module Boa
  class BoaConfigError < StandardError; end
  class BoaPluginError < StandardError; end
end

$boa = Boa::Config.instance
