require 'rainbow'
require 'sprockets'
require 'forwardable'

module Jasmine::Headless
  class RequiredFile
    extend Forwardable

    def_delegators :parent, :path_searcher, :extension_filter

    attr_reader :path, :source_root, :parent
    attr_writer :spec_file

    def initialize(path, source_root, parent)
      @path, @source_root, @parent = path, source_root, parent
      @spec_file = false
    end

    def spec_file?
      @spec_file
    end

    def ==(other)
      self.path == other.path
    end

    def to_html
      process_data_by_filename(path)
    end

    def has_dependencies?
      !dependencies.empty?
    end

    def includes?(path)
      @path == path || dependencies.any? { |dependency| dependency.includes?(path) }
    end

    def file_paths
      paths = dependencies.collect(&:file_paths).flatten

      if @insert_after
        paths.insert(paths.index(@insert_after) + 1, path)
      else
        paths << path
      end

      paths
    end

    def dependencies
      return @dependencies if @dependencies

      processor = Sprockets::DirectiveProcessor.new(path)

      last_file_added = nil

      @dependencies = processor.directives.collect do |line, type, name|
        if name && name[%r{^\.}]
          name = File.expand_path(File.join(File.dirname(path), name)).gsub(%r{^#{source_root}/}, '')
        else
          raise Sprockets::ArgumentError.new("require_tree needs a relative path: ./#{path}") if type == 'require_tree'
        end

        files = case type
        when 'require'
          [ name ]
        when 'require_tree'
          Dir[File.join(source_root, name, '**/*')].find_all { |found_path|
            found_path != path && File.file?(found_path) && found_path[extension_filter]
          }.sort.collect { |path| path.gsub(%r{^#{source_root}/}, '') }
        when 'require_self'
          @insert_after = last_file_added
          []
        else
          []
        end

        files.collect do |file|
          if result = path_searcher.find(file)
            new_file = self.class.new(*[ result, self ].flatten)
            last_file_added = new_file.path
            new_file
          else
            raise Sprockets::FileNotFound.new("Could not find #{file}, referenced from #{path}:#{line}")
          end
        end
      end.flatten
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
          data = %{<script type="text/javascript">#{data}</script>} if extension == '.jst'

          process_data_by_filename(path.gsub(%r{#{extension}$}, ''), data)
        else
          data || ''
        end
      end
    end
  end
end

