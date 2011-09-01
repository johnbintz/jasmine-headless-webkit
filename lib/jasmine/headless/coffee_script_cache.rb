require 'coffee_script'
require 'digest/sha1'
require 'fileutils'

module Jasmine
  module Headless
    class CoffeeScriptCache
      class << self
        def enabled=(bool)
          @enabled = bool
        end

        def enabled?
          @enabled = true if @enabled == nil
          @enabled
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
        if self.class.enabled?
          if fresh?
            File.read(cache_file)
          else
            result = compile
            FileUtils.mkdir_p self.class.cache_dir
            File.open(cache_file, 'wb') { |fh| fh.print result }
            result
          end
        else
          compile
        end
      end

      def cache_file
        @cache_file ||= File.join(self.class.cache_dir, Digest::SHA1.hexdigest(file))
      end

      def fresh?
        File.exist?(cache_file) && (File.mtime(file) < File.mtime(cache_file))
      end

      def compile
        CoffeeScript.compile(File.read(file))
      end
    end
  end
end

