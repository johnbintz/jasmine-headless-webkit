require 'execjs'
require 'digest/sha1'
require 'fileutils'

module Jasmine
  module Headless

    class DustCache < CacheableAction

      class << self
        def cache_type
          "dust"
        end
      end

      def action
        @path ||= File.expand_path('../../../../vendor/assets/javascripts/dust-full-for-compile.js', __FILE__)
        @contents ||= File.read(@path)
        @context ||= ExecJS.compile(@contents)

        template_root = DustTemplate.template_root
        template_root = template_root + '/' if template_root[ template_root.length - 1 ].chr != '/'
        template_name = file.split(template_root).last.split('.',2).first
        @context.call("dust.compile", File.read(file), template_name)
      end
    end
  end
end


