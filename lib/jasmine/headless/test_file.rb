require 'rainbow'
require 'sprockets'

%w{haml-sprockets}.each do |library|
  begin
    require library
  rescue LoadError
  end
end

module Jasmine::Headless
  class TestFile
    attr_reader :path, :source_root

    def initialize(path, source_root = nil)
      @path, @source_root = path, source_root
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
          puts "[%s] %s: %s" % [ 'coffeescript'.color(:red), path.color(:yellow), ne.message.dup.to_s.color(:white) ]
          raise ne
        rescue StandardError => e
          puts "[%s] Error in compiling file: %s" % [ 'coffeescript'.color(:red), path.color(:yellow) ]
          raise e
        end
      when '.js'
        %{<script type="text/javascript" src="#{path}"></script>}
      when '.css'
        %{<link rel="stylesheet" href="#{path}" type="text/css" />}
      when '.jst'
        to_jst(read)
      else
        case path
        when %r{\.jst(\..*)$}
          to_jst(Sprockets.engines($1).new { read }.evaluate(self, {}))
        end
      end
    end

    def dependencies
      return @dependencies if @dependencies

      processor = Sprockets::DirectiveProcessor.new(path)
      @dependencies = processor.directives.collect do |_, type, name|
        if name[%r{^\.}]
          name = File.expand_path(File.join(File.dirname(path), name)).gsub(%r{^#{source_root}/}, '')
        end

        [ type, name ]
      end
    end

    def logical_path
      path.gsub(%r{^#{source_root}/}, '').gsub(%r{\..+$}, '')
    end

    private
    def to_jst(data)
      %{<script type="text/javascript">#{Sprockets.engines('.jst').new { data }.evaluate(self, {})}</script>}
    end

    def read
      File.read(path)
    end
  end
end

