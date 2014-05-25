require 'coffee_script'
require 'digest/sha1'
require 'fileutils'

module Jasmine
  module Headless
    class CoffeeScriptCache < CacheableAction
      class << self
        def cache_type
          "coffee_script"
        end
      end

      def action
        CoffeeScript.compile(File.read(file))
      end

      def relative_cache_file
        super.gsub(/.coffee$/, '')
      end

    end
  end
end

