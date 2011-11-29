module Jasmine::Headless
  class CacheableAction
    class << self
      def enabled=(bool)
        @enabled = bool
      end

      def enabled?
        @enabled = true if @enabled == nil
        @enabled
      end

      def cache_type
        raise ArgumentError.new("No cache type defined for #{self.name}") if @cache_type == nil
        @cache_type
      end

      def cache_type=(type)
        @cache_type = type
      end

      def cache_dir=(dir)
        @cache_dir = dir
      end

      def cache_dir
        @cache_dir ||= '.jhw-cache'
      end

      def for(file)
        new(file).handle
      end
    end

    attr_reader :file

    def initialize(file)
      @file = file
    end

    def handle
      if CacheableAction.enabled?
        if fresh?
          unserialize(File.read(cache_file))
        else
          result = action
          FileUtils.mkdir_p File.split(cache_file).first
          File.open(cache_file, 'wb') { |fh| fh.print serialize(result) }
          result
        end
      else
        action
      end
    end

    def cache_file
      @cache_file ||= File.expand_path(File.join(self.class.cache_dir, self.class.cache_type, file)) + '.js'
    end

    def fresh?
      cached? && (File.mtime(file) < File.mtime(cache_file))
    end

    def cached?
      File.exist?(cache_file)
    end

    def action
      raise StandardError.new("Override action")
    end

    def serialize(data)
      data
    end

    def unserialize(data)
      data
    end
  end
end

