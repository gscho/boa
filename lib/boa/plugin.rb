# frozen_string_literal: true

module Boa
  module Plugin
    def self.register(type, klass)
      raise BoaPluginError, "Invalid plugin definition for: '#{type}'. Plugin must be a Class" unless klass.is_a?(Class)

      @plugins[type] = klass.new
    end

    def self.plugin_for_type(type)
      @plugins ||= {}
      return @plugins[type] unless @plugins[type].nil?

      Boa::Plugin.search(type)
      raise BoaPluginError, "Unable to find a plugin for type: '#{type}'" if @plugins[type].nil?

      @plugins[type]
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    def self.search(type)
      path = "boa/plugin/boa_#{type}"
      files = $LOAD_PATH.map do |lp|
        lpath = File.expand_path(File.join(lp, "#{path}.rb"))
        File.exist?(lpath) ? lpath : nil
      end.compact

      unless files.empty?
        require files.max
        return
      end

      specs = Gem::Specification.find_all do |spec|
        spec.contains_requirable_file? path
      end.sort_by(&:version)

      spec = specs.last
      return unless spec

      spec.require_paths.each do |lib|
        file = "#{spec.full_gem_path}/#{lib}/#{path}"
        if File.exist?("#{file}.rb")
          require file
          break
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
  end
end
