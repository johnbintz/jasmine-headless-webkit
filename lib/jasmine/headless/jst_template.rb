require 'sprockets/jst_processor'

module Jasmine::Headless
  class JSTTemplate < Sprockets::JstProcessor
    include Jasmine::Headless::FileChecker
    def evaluate(*args)
      if bad_format?(file)
        alert_bad_format(file)
        return ''
      end
      begin
        data = super
        cache = Jasmine::Headless::JSTTemplateCache.new(file, data)

        source = cache.handle
        if cache.cached?
          %{<script type="text/javascript" src="#{cache.cache_file}"></script>
            <script type="text/javascript">window.CSTF['#{File.split(cache.cache_file).last}'] = '#{file}';</script>}
        else
          %{<script type="text/javascript">#{source}</script>}
        end
      rescue StandardError => e
        puts "[%s] Error in compiling file: %s" % [ 'jst'.color(:red), file.color(:yellow) ]
        raise e
      end      
    end
  end
end

