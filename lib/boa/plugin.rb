# frozen_string_literal: true

module Boa
  module Plugin
    def self.register(type, klass)
      if !klass.is_a?(Class)
        raise BoaPluginError, "Invalid plugin definition for: '#{type}'. Plugin must be a Class"
      end
      @plugins[type] = klass.new
    end

    private

    def self.plugin_for_type(type)
      @plugins ||= {}
      return @plugins[type] unless @plugins[type].nil?
      Boa::Plugin.search(type)
      raise BoaPluginError, "Unable to find a plugin for type: '#{type}'" if @plugins[type].nil?
      
      @plugins[type]
    end

    def self.search(type)
      path = "boa/plugin/boa_#{type}"
      files = $LOAD_PATH.map do |lp|
        lpath = File.expand_path(File.join(lp, "#{path}.rb"))
        File.exist?(lpath) ? lpath : nil
      end.compact
      
      unless files.empty?
        require files.sort.last
        return
      end

      specs = Gem::Specification.find_all do |spec|
        spec.contains_requirable_file? path
      end.sort_by { |spec| spec.version }

      spec = specs.last
      if spec
        spec.require_paths.each do |lib|
          file = "#{spec.full_gem_path}/#{lib}/#{path}"
          if File.exist?("#{file}.rb")
            require file
            return
          end
        end
      end
    end
  end
end