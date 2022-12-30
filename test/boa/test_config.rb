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
    assert_equal "localhost", $boa.get("redis.host")
    assert_equal 6379, $boa.get("redis.port")
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
    assert_equal "localhost", $boa.get("redis.host")
    assert_equal 6379, $boa.get("redis.port")
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
    assert_equal "bar", $boa.get("foo")
  end

  def test_it_raises_when_no_type_given
    $boa.set_config_name("config")
    assert_raises(Boa::BoaConfigError) do
      $boa.read_in_config
    end
  end

  def test_it_raises_when_no_config_file_found
    $boa.set_config_name("config.fake")
    assert_raises(Boa::BoaConfigError) do
      $boa.read_in_config
    end
  end

  def test_it_raises_when_no_plugin_for_type
    $boa.set_config_name("config.unsupported")
    $boa.add_config_path(File.join(__dir__, "../fixtures"))
    assert_raises(Boa::BoaPluginError) do
      $boa.read_in_config
    end
  end

  def test_get_value_at_path
    hash = {
      "deeply" =>{
        "nested" => {
          "redis" => {
            "host" => "localhost"
          }
        }
      }
    }

    tmp = {
      "nested" => {
        "redis" => {
          "host" => "localhost"
        }
      }
    }
    assert_equal tmp, $boa.value_at_path(hash, "deeply")
    tmp = {
      "redis" => {
        "host" => "localhost"
      }
    }
    assert_equal tmp, $boa.value_at_path(hash, "deeply.nested")
    tmp = {"host" => "localhost"}
    assert_equal tmp, $boa.value_at_path(hash, "deeply.nested.redis")
    assert_equal "localhost", $boa.value_at_path(hash, "deeply.nested.redis.host")
    assert_nil $boa.value_at_path(hash, "not")
    assert_nil $boa.value_at_path(hash, "deeply.nested.redis.host.not")
    assert_equal "localhost", $boa.value_at_path(hash, "DEEPLY.NESTED.REDIS.HOST")
    assert_equal "localhost", $boa.value_at_path(hash, "deeply.NESTED.redis.HOST")
    assert_equal "localhost", $boa.value_at_path(hash, "dEEplY.NEsTed.reDIS.HoSt")
  end

  def test_it_gets
    config = <<-YAML
    deeply:
      nested:
        redis:
          host: "localhost"
    YAML
    $boa.set_config_type("yaml")
    $boa.read_config(config)
    assert_equal "localhost", $boa.get("deeply.nested.redis.host")
  end

  def test_it_gets_float
    config = <<-YAML
    deeply:
      nested:
        redis:
          host: "localhost"
          floatval: 1.1
    YAML
    $boa.set_config_type("yaml")
    $boa.read_config(config)
    assert_equal 1.1, $boa.get_float("deeply.nested.redis.floatval")
    assert_equal 0.0, $boa.get_float("deeply.nested.redis.host")
  end

  def test_it_gets_int
    config = <<-YAML
    deeply:
      nested:
        redis:
          host: "localhost"
          port: 6379
    YAML
    $boa.set_config_type("yaml")
    $boa.read_config(config)
    assert_equal 6379, $boa.get_int("deeply.nested.redis.port")
    assert_equal 0, $boa.get_int("deeply.nested.redis.host")
  end

  def test_it_gets_int_array
    config = <<-YAML
    deeply:
      nested:
        redis:
          host: "localhost"
          ports:
          - 6379
          - 6380
    YAML
    $boa.set_config_type("yaml")
    $boa.read_config(config)
    assert_equal [6379, 6380], $boa.get_int_array("deeply.nested.redis.ports")
    assert_raises(Boa::BoaConfigError) do 
      $boa.get_int_array("deeply.nested.redis.host")
    end
  end

  def test_it_gets_string
    config = <<-YAML
    deeply:
      nested:
        redis:
          host: "localhost"
          ports:
          - 6379
          - 6380
    YAML
    $boa.set_config_type("yaml")
    $boa.read_config(config)
    assert_equal "localhost", $boa.get_string("deeply.nested.redis.host")
  end

  def test_it_gets_string_hash
    config = <<-YAML
    deeply:
      nested:
        redis:
          host: "localhost"
          ports:
          - 6379
          - 6380
    YAML
    $boa.set_config_type("yaml")
    $boa.read_config(config)
    $boa.get_string_hash("deeply").each_key {|k| assert_equal true, k.is_a?(String)}
  end

  def test_it_gets_string_array
    config = <<-YAML
    deeply:
      nested:
        redis:
          host: "localhost"
          ports:
          - 6379
          - 6380
    YAML
    $boa.set_config_type("yaml")
    $boa.read_config(config)
    $boa.get_string_array("deeply.nested.redis.ports").each {|k| assert_equal true, k.is_a?(String)}
  end

  def test_set?
    config = <<-YAML
    deeply:
      nested:
        redis:
          host: "localhost"
    YAML
    $boa.set_config_type("yaml")
    $boa.read_config(config)
    assert_equal true, $boa.set?("deeply")
    assert_equal true, $boa.set?("deeply.nested")
    assert_equal true, $boa.set?("deeply.nested.redis")
    assert_equal true, $boa.set?("deeply.nested.redis.host")
    assert_equal false, $boa.set?("not")
    assert_equal false, $boa.set?("not.set")
  end

  def test_its_binds_env
    ENV["FOO"] = "bar"
    $boa.bind_env("MY_VALUE", "FOO")
    assert_equal "bar", $boa.get("my_value")
    $boa.bind_env("MY_VALUE", "BAZ", "FOO")
    assert_equal "bar", $boa.get("my_value")
    ENV["BOB"] = "vance"
    $boa.bind_env("MY_VALUE", "BAZ", "BOB", "FOO")
    assert_equal "vance", $boa.get("my_value")
  end

  def test_its_sets_env_prefix
    ENV["SPF_ID"] = "13"
    $boa.set_env_prefix("spf")
    $boa.bind_env("id")
    assert_equal "13", $boa.get("id")
  end

  def test_it_uses_automatic_env
    ENV["SPF_ID"] = "13"
    config = <<-YAML
    SPF_ID: 12
    YAML
    $boa.set_env_prefix("spf")
    $boa.set_config_type("yaml")
    $boa.read_config(config)
    $boa.automatic_env
    assert_equal "13", $boa.get("id")
  end

  def test_it_writes_config
    config = <<-YAML
    deeply:
      nested:
        redis:
          host: "localhost"
    YAML
    $boa.set_config_type("yaml")
    $boa.read_config(config)
    assert_raises(Boa::BoaConfigError) do
      $boa.write_config
    end
    $boa.set_config_name("write_config")
    $boa.add_config_path(File.join(__dir__, "../fixtures"))
    $boa.set("deeply.nested.redis.host", "http://localhost")
    $boa.set("deeply.nested.redis.port", 6379)
    $boa.write_config
    assert_equal true, File.exist?(File.join(__dir__, "../fixtures", "write_config.yaml"))
    require "yaml"
    parsed = YAML.load(File.read(File.join(__dir__, "../fixtures", "write_config.yaml")))
    assert_equal "http://localhost", parsed["deeply"]["nested"]["redis"]["host"]
    assert_equal 6379, parsed["deeply"]["nested"]["redis"]["port"]
    File.delete(File.join(__dir__, "../fixtures", "write_config.yaml"))
  end
end
