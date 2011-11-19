require 'rainbow'
require 'sprockets'

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
      process_data_by_filename(path)
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
    def read
      File.read(path)
    end

    def process_data_by_filename(path, data = nil)
      case extension = File.extname(path)
      when ''
        data || ''
      when '.js'
        data || %{<script type="text/javascript" src="#{path}"></script>}
      when '.css'
        data || %{<link rel="stylesheet" href="#{path}" type="text/css" />}
      else
        if engine = Sprockets.engines(extension)
          data = engine.new(path) { data || read }.render(self)

          process_data_by_filename(path.gsub(%r{#{extension}$}, ''), data)
        else
          data || ''
        end
      end
    end
  end
end

