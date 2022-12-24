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
      @type = type
    end

    def add_config_path(path)
      @config_paths << path
    end

    def read_in_config
      @type = File.extname(@name) unless @type
      raise "Must provide an extension in the config name or explicitly set the config type" unless @type

      file = [File.basename(@name), @type].join(".")
      config_dir = @config_paths.find { |p| File.exist?(File.join(p, file)) }
      file_path = File.join(config_dir, file)
      parse_config(File.read(file_path))
    end

    # used for unit tests
    def reset!
      @config = {}
      @config_paths = []
      @name = nil
      @type = nil
    end

    def parse_config(file)
      serde = Boa::Plugin.plugin_for_type(@type)
      parsed = serde.deserialize(file)
      @config.merge! parsed
    end
  end
end