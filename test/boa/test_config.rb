# frozen_string_literal: true

require "test_helper"

class TestBoaConfig < Minitest::Test

  def setup
    $boa.reset!  
  end

  def test_it_has_a_config
    assert $boa.config != nil
  end

  def test_it_has_config_paths
    assert $boa.config_paths != nil
  end

  def test_it_adds_config_paths
    $boa.add_config_path "/etc/appname/"
    $boa.add_config_path "$HOME/.appname"
    $boa.add_config_path "."
    assert_equal ["/etc/appname/", "$HOME/.appname", "."], $boa.config_paths
  end

  def test_read_in_json_config
    $boa.set_config_name("config")
    $boa.set_config_type("json")
    $boa.add_config_path(File.join(__dir__, "../fixtures"))
    $boa.read_in_config
    expected = {
      "redis" => {
        "host" => "localhost", 
        "port" => 6379
      }
    }
    assert_equal expected, $boa.config
  end

  def test_read_in_yaml_config
    $boa.set_config_name("config")
    $boa.set_config_type("yaml")
    $boa.add_config_path(File.join(__dir__, "../fixtures"))
    $boa.read_in_config
    expected = {
      "redis" => {
        "host" => "localhost", 
        "port" => 6379
      }
    }
    assert_equal expected, $boa.config
  end

  def test_load_plugin_foo
    $boa.set_config_name("config")
    $boa.set_config_type("foo")
    $boa.add_config_path(File.join(__dir__, "../fixtures"))
    $boa.read_in_config
    expected = {
      "foo" => "bar"
    }
    assert_equal expected, $boa.config
  end
end
