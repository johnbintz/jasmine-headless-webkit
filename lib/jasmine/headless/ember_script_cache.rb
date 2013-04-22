require 'ember_script'
require 'digest/sha1'
require 'fileutils'

module Jasmine
  module Headless
    class EmberScriptCache < CacheableAction
      class << self
        def cache_type
          "ember_script"
        end
      end

      def action
        EmberScript.compile(File.read(file))
      end
    end
  end
end

