# frozen_string_literal: true

require "singleton"

module Boa
  class Config
    include Singleton
    attr_reader :config, :config_paths, :name, :type

    def initialize
      @config = {}
      @config_paths = []
      @env_prefix = ""
    end

    # Mainly for unit tests
    def reset!
      @config = {}
      @config_paths = []
      @env_prefix = ""
      @name = nil
      @type = nil
    end

    def set_default(key, val)
      @config[key.to_s] = val
    end

    def set_config_name(name)
      @name = name
    end

    def set_config_type(type)
      @type = type.delete_prefix(".")
    end

    def add_config_path(path)
      @config_paths << path
    end

    def read_config(config_string)
      raise BoaConfigError, "Must provide the config type before calling read_config" if @type.empty?

      read_config_from(config_string)
    end

    def read_in_config
      @type ||= File.extname(@name).delete_prefix(".")
      if @type.empty?
        raise BoaConfigError,
              "Must provide an extension in the config name or explicitly set the config type"
      end

      file = "#{File.basename(@name, ".#{@type}")}.#{@type}"
      config_dir = @config_paths.find { |p| File.exist?(File.join(p, file)) }
      if config_dir.nil?
        raise BoaConfigError,
              "Unable to locate a config file named: '#{file}' at the provided config paths."
      end

      file_path = File.join(config_dir, file)
      read_config_from(File.read(file_path))
    end

    def get(key)
      key = @env_prefix + key
      return ENV.fetch(key.upcase, value_at_path(@config, key)) if @automatic_env

      value_at_path(@config, key)
    end

    def get_float(key)
      get(key).to_f
    end

    def get_int(key)
      get(key).to_i
    end

    def get_int_array(key)
      key = @env_prefix + key
      value = value_at_path(@config, key)
      return value if value.nil?
      raise BoaConfigError, "Value at key: '#{key}' is not an array" unless value.is_a?(Array)

      value.map(&:to_i)
    end

    def get_string(key)
      get(key).to_s
    end

    def get_string_hash(key)
      key = @env_prefix + key
      value = value_at_path(@config, key)
      return value if value.nil?
      raise BoaConfigError, "Value at key: '#{key}' is not a hash" unless value.is_a?(Hash)

      value.transform_keys(&:to_s)
    end

    def get_string_array(key)
      value = value_at_path(@config, key)
      return value if value.nil?
      raise BoaConfigError, "Value at key: '#{key}' is not an array" unless value.is_a?(Array)

      value.map(&:to_s)
    end

    def set(key, value)
      set_value_at_path(@config, key, value)
    end

    def set?(key)
      value = get(key)
      !value.nil? && !value.empty?
    end

    def all_settings
      @config
    end

    def write_config
      raise BoaConfigError, "No config paths added" if config_paths.empty?

      write_config_as(config_paths.first)
    end

    def safe_write_config
      raise BoaConfigError, "No config paths added" if config_paths.empty?

      safe_write_config_as(config_paths.first)
    end

    def write_config_as(path)
      @type ||= File.extname(@name).delete_prefix(".")
      if @type.empty?
        raise BoaConfigError,
              "Must provide an extension in the config name or explicitly set the config type"
      end

      file = "#{File.basename(@name, ".#{@type}")}.#{@type}"
      path = File.join(path, file)

      write_config_to(path)
    end

    def safe_write_config_as(path)
      raise BoaConfigError, "Config file: '#{path}' already exists" if File.exist?(path)

      write_config_as(path)
    end

    def set_env_prefix(prefix)
      @env_prefix = "#{prefix.upcase}_"
    end

    def bind_env(key, *names)
      if names.any?
        key = key.upcase
        names.each do |n|
          value = ENV.fetch(n, nil)
          if value
            @config[key] = value
            break
          end
        end
      else
        key = @env_prefix + key.upcase
        @config[key] = ENV.fetch(key, nil)
      end
    end

    def automatic_env
      @automatic_env = true
    end

    def value_at_path(hash, nested_path)
      path = nested_path.split(".")
      at_path = hash[path[0].downcase]
      at_path = hash[path[0].upcase] if at_path.nil?
      return at_path if path.size == 1 || at_path.nil?

      path.shift
      value_at_path(at_path, path.join("."))
    end

    def set_value_at_path(hash, nested_path, value)
      path = nested_path.split(".")
      at_path = hash[path[0].downcase]
      at_path = hash[path[0].upcase] if at_path.nil?
      if path.size == 1
        hash[path[0]] = value
        return
      end
      path.shift
      set_value_at_path(at_path, path.join("."), value)
    rescue NoMethodError
      raise BoaConfigError, "Unable to modify config at: '#{nested_path}' because parent is nil or not a hash"
    end

    private

    def read_config_from(file)
      serde = Boa::Plugin.plugin_for_type(@type)
      parsed = serde.deserialize(file)
      @config.merge! parsed
    end

    def write_config_to(path)
      serde = Boa::Plugin.plugin_for_type(@type)
      File.write(path, serde.serialize(@config))
    end
  end
end
