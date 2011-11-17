require 'rainbow'

module Jasmine::Headless
  class TestFile
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def ==(other)
      self.path == other.path
    end

    def to_html
      case File.extname(path)
      when '.coffee'
        begin
          cache = Jasmine::Headless::CoffeeScriptCache.new(path)
          source = cache.handle
          if cache.cached?
            %{<script type="text/javascript" src="#{cache.cache_file}"></script>
              <script type="text/javascript">
                window.CSTF['#{File.split(cache.cache_file).last}'] = '#{path}';
              </script>}
          else
            %{<script type="text/javascript">#{source}</script>}
          end
        rescue CoffeeScript::CompilationError => ne
          puts "[%s] %s: %s" % [ 'coffeescript'.color(:red), path.color(:yellow), ne.message.to_s.color(:white) ]
          raise ne
        rescue StandardError => e
          puts "[%s] Error in compiling file: %s" % [ 'coffeescript'.color(:red), path.color(:yellow) ]
          raise e
        end
      when '.js'
        %{<script type="text/javascript" src="#{path}"></script>}
      when '.css'
        %{<link rel="stylesheet" href="#{path}" type="text/css" />}
      end
    end
  end
end
