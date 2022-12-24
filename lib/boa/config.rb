# frozen_string_literal: true
require "singleton"

module Boa
  class Config
    include Singleton
    attr_reader :config, :config_paths, :name, :type
    
    def initialize
      @config = {}
      @config_paths = []
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

      parse_config(config_string)
    end

    def read_in_config
      @type = File.extname(@name).delete_prefix(".") unless @type
      raise BoaConfigError, "Must provide an extension in the config name or explicitly set the config type" if @type.empty?

      file = "#{File.basename(@name, ".#{@type}")}.#{@type}"
      config_dir = @config_paths.find { |p| File.exist?(File.join(p, file)) }
      raise BoaConfigError, "Unable to locate a config file named: '#{file}' at the provided config paths." if config_dir.nil?

      file_path = File.join(config_dir, file)
      parse_config(File.read(file_path))
    end

    def get(key)
      value_at_path(@config, key)
    end

    def get_float(key)
      value_at_path(@config, key).to_f
    end

    def get_int(key)
      value_at_path(@config, key).to_i
    end

    def get_int_array(key)
      value = value_at_path(@config, key)
      return value if value.nil?
      raise BoaConfigError, "Value at key: '#{key}' is not an array" unless value.is_a?(Array)

      value.map(&:to_i)
    end

    def get_string(key)
      value_at_path(@config, key).to_s
    end

    def get_string_hash(key)
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

    def set?(key)
      value = get(key)
      value != nil && !value.empty?
    end

    def all_settings
      @config
    end

    # used for unit tests
    def reset!
      @config = {}
      @config_paths = []
      @name = nil
      @type = nil
    end
    
    def value_at_path(hash, nested_path)
      path = nested_path.split(".")
      at_path = hash[path[0]]
      return at_path if path.size == 1 || at_path.nil?
      path.shift
      value_at_path(at_path, path.join("."))
    end

    private

    def parse_config(file)
      serde = Boa::Plugin.plugin_for_type(@type)
      parsed = serde.deserialize(file)
      @config.merge! parsed
    end
  end
end