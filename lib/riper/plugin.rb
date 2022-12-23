# frozen_string_literal: true

module Riper
  module Plugin
    def self.register(type, klass)
      if !klass.is_a?(Class)
        raise RiperPluginError, "Invalid plugin: '#{type}'. It must be a Class"
      end
      @plugins[type] = klass.new
    end

    private

    def self.plugin_for_type(type)
      @plugins ||= {}
      return @plugins[type] unless @plugins[type].nil?
      Riper::Plugin.search(type)
      @plugins[type]
    end

    def self.search(type)
      path = "riper/plugin/riper_#{type}"
      files = $LOAD_PATH.map do |lp|
        lpath = File.expand_path(File.join(lp, "#{path}.rb"))
        File.exist?(lpath) ? lpath : nil
      end.compact
      
      unless files.empty?
        require files.sort.last
        return
      end

      specs = Gem::Specification.find_all do |spec|
        puts path
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