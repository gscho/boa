# frozen_string_literal: true

require "test_helper"

class TestRiper < Minitest::Test

  def setup
    $riper.reset!  
  end

  def test_it_has_a_config
    assert $riper.config != nil
  end

  def test_it_has_config_paths
    assert $riper.config_paths != nil
  end

  def test_it_adds_config_paths
    $riper.add_config_path "/etc/appname/"
    $riper.add_config_path "$HOME/.appname"
    $riper.add_config_path "."
    assert_equal ["/etc/appname/", "$HOME/.appname", "."], $riper.config_paths
  end

  def test_read_in_json_config
    $riper.set_config_name("config")
    $riper.set_config_type("json")
    $riper.add_config_path(File.join(__dir__, "fixtures"))
    $riper.read_in_config
    expected = {
      "redis" => {
        "host" => "localhost", 
        "port" => 6379
      }
    }
    assert_equal expected, $riper.config
  end

  def test_read_in_yaml_config
    $riper.set_config_name("config")
    $riper.set_config_type("yaml")
    $riper.add_config_path(File.join(__dir__, "fixtures"))
    $riper.read_in_config
    expected = {
      "redis" => {
        "host" => "localhost", 
        "port" => 6379
      }
    }
    assert_equal expected, $riper.config
  end

  def test_load_plugin_foo
    $riper.set_config_name("config")
    $riper.set_config_type("foo")
    $riper.add_config_path(File.join(__dir__, "fixtures"))
    $riper.read_in_config
    expected = {
      "foo" => "bar"
    }
    assert_equal expected, $riper.config
  end
end
