# frozen_string_literal: true

require "boa"

$boa.automatic_env
$boa.set_config_name("my_config.yaml")
$boa.add_config_path(".")
$boa.read_in_config

set :server, $boa.get("app.server")
set :port, $boa.get("app.port")
