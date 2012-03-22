require 'tilt/template'
require 'execjs'

module Jasmine::Headless
  class DustTemplate < Tilt::Template
    include Jasmine::Headless::FileChecker

    class << self
      def template_root=(root)
        @template_root = root
      end
      def template_root
        @template_root || "app/assets/javascripts/templates/"
      end
    end

    self.default_mime_type = 'application/javascript'

    def prepare; end

    def evaluate(scope, locals, &block)
      if bad_format?(file)
        alert_bad_format(file)
        return ''
      end
      begin
        cache = Jasmine::Headless::DustCache.new(file)
        source = cache.handle
        if cache.cached?
          %{<script type="text/javascript" src="#{cache.cache_file}"></script>
            <script type="text/javascript">window.CSTF['#{File.split(cache.cache_file).last}'] = '#{file}';</script>}
        else
          %{<script type="text/javascript">#{source}</script>}
        end
      rescue StandardError => e
        puts "[%s] Error in compiling file: %s" % [ 'coffeescript'.color(:red), file.color(:yellow) ]
        raise e
      end
    end
  end
end
