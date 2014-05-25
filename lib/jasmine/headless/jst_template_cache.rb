require 'sprockets/jst_processor'
require 'digest/sha1'
require 'fileutils'

module Jasmine
  module Headless
    class JSTTemplateCache < CacheableAction

      def initialize(file, data)
        @file = file 
        @data = data
      end

      class << self
        def cache_type
          "jst_template"
        end
      end

      def action
        @data
      end
    end
  end
end

