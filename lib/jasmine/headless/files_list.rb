require 'jasmine-core'
require 'time'
require 'multi_json'
require 'set'
require 'sprockets'

module Jasmine::Headless
  class FilesList
    class << self
      def vendor_asset_paths
        return @vendor_asset_paths if @vendor_asset_paths

        require 'rubygems'

        raise StandardError.new("A newer version of Rubygems is required to use vendored assets. Please upgrade.") if !Gem::Specification.respond_to?(:map)

        @vendor_asset_paths = []

        Gem::Specification.map { |spec|
          path = File.join(spec.gem_dir, 'vendor/assets/javascripts')

          File.directory?(path) ? path : nil
        }.compact
      end

      def reset!
        @vendor_asset_paths = nil
      end
    end

    DEFAULT_FILES = %w{jasmine.js jasmine-html jasmine.css jasmine-extensions intense headless_reporter_result jasmine.HeadlessConsoleReporter jsDump beautify-html}

    PLEASE_WAIT_IM_WORKING_TIME = 2

    def initialize(options = {})
      @options = options

      @files = []
      @filtered_files = []
      @checked_dependency = Set.new

      DEFAULT_FILES.each { |file| add_dependency('require', file, nil) }

      @spec_outside_scope = false
      @spec_files = []

      use_config! if config?
    end

    def files
      @files.to_a
    end

    def filtered_files
      @filtered_files.to_a
    end

    def spec_files
      @spec_files.to_a
    end

    def search_paths
      return @search_paths if @search_paths

      @search_paths = [ Jasmine::Core.path ]
      @search_paths += [ src_dir ].flatten.collect { |dir| File.expand_path(dir) }
      @search_paths << File.expand_path(spec_dir)
      @search_paths += self.class.vendor_asset_paths

      @search_paths
    end

    def has_spec_outside_scope?
      @spec_outside_scope
    end

    def filtered?
      files != filtered_files
    end

    def files_to_html
      to_html(files)
    end

    def filtered_files_to_html
      to_html(filtered_files)
    end

    def spec_file_line_numbers
      @spec_file_line_numbers ||= Hash[@spec_files.collect { |file|
        if File.exist?(file)
          if !(lines = Jasmine::Headless::SpecFileAnalyzer.for(file)).empty?
            [ file, lines ]
          end
        else
          nil
        end
      }.compact]
    end

    def add_dependencies(file, source_root)
      TestFile.new(file, source_root).dependencies.each do |type, name|
        add_dependency(type, name, source_root)
      end
    end

    def extension_filter
      %r{(#{(%w{.js .css} + Sprockets.engine_extensions).join('|')})$}
    end

    def add_dependency(type, file, source_root)
      files = case type
      when 'require'
        if !@checked_dependency.include?(file)
          @checked_dependency << file

          [ file ]
        else
          []
        end
      when 'require_tree'
        Dir[File.join(source_root, file, '**/*')].find_all { |path|
          File.file?(path) && path[extension_filter] 
        }.sort.collect { |path| path.gsub(%r{^#{source_root}/}, '') }
      else
        []
      end

      files.each do |file|
        if result = find_dependency(file)
          add_file(result[0], result[1], false)
        end
      end
    end

    def find_dependency(file)
      search_paths.each do |dir|
        Dir[File.join(dir, "#{file}*")].find_all { |path| File.file?(path) }.each do |path|
          root = path.gsub(%r{^#{dir}/}, '')

          ok = (root == file)
          ok ||= File.basename(path.gsub("#{file}.", '')).split('.').all? { |part| ".#{part}"[extension_filter] }

          expanded_path = File.expand_path(path)

          if ok
            return [ expanded_path, File.expand_path(dir) ]
          end
        end
      end

      false
    end

    private
    def to_html(files)
      alert_time = Time.now + PLEASE_WAIT_IM_WORKING_TIME

      files.collect { |file|
        if alert_time && alert_time < Time.now
          puts "Rebuilding cache, please wait..."
          alert_time = nil
        end

        search_paths.collect do |path|
          if file[path]
            Jasmine::Headless::TestFile.new(file, path).to_html
          end
        end.compact.first
      }.flatten.compact.reject(&:empty?)
    end

    def spec_filter
      return @spec_filter if @spec_filter

      @spec_filter = begin
                       if @options[:only]
                         @options[:only].collect { |path| expanded_dir(path) }.flatten
                       else
                         []
                       end
                     end
    end

    SEARCH_ROOTS = {
      'src_files' => 'src_dir',
      'stylesheets' => 'src_dir',
      'helpers' => 'spec_dir',
      'spec_files' => 'spec_dir'
    }

    def use_config!
      @filtered_files = @files.dup

      @config = @options[:config].dup

      %w{src_files stylesheets helpers spec_files}.each do |searches|
        if data = @config[searches]
          add_files(data.flatten, searches)
        end
      end
    end

    def add_files(searches, type)
      searches.each do |search|
        [ @config[SEARCH_ROOTS[type]] || Dir.pwd ].flatten.each do |dir|
          dir = File.expand_path(dir)

          path = File.expand_path(File.join(dir, search))

          found_files = expanded_dir(path) - files

          found_files.each do |file|
            type == 'spec_files' ? add_spec_file(file) : add_file(file, dir)
          end
        end
      end

      if type == 'spec_files'
        spec_filter.each do |file|
          @spec_outside_scope ||= add_spec_file(file)
        end
      end
    end

    def config?
      @options[:config]
    end

    def expanded_dir(path)
      Dir[path].collect { |file| File.expand_path(file) }.find_all { |path| File.file?(path) && path[extension_filter] }
    end

    def add_file(file, source_root, clear_dependencies = true)
      @checked_dependency = Set.new if clear_dependencies

      add_dependencies(file, source_root)

      @files << file if !@files.include?(file)
      @filtered_files << file if !@filtered_files.include?(file)
    end

    def add_spec_file(file)
      add_dependencies(file, spec_dir)

      if !@files.include?(file)
        @files << file if !@files.include?(file)

        if include_spec_file?(file)
          @filtered_files << file if !@filtered_files.include?(file)
          @spec_files << file if !@spec_files.include?(file) && spec_filter.empty? || spec_filter.include?(file)
        end

        true
      end
    end

    def include_spec_file?(file)
      spec_filter.empty? || spec_filter.include?(file)
    end

    def src_dir
      config_dir_or_pwd('src_dir')
    end

    def spec_dir
      config_dir_or_pwd('spec_dir')
    end

    def config_dir_or_pwd(dir)
      found_dir = Dir.pwd

      if @options[:config]
        found_dir = @options[:config][dir] || found_dir
      end

      found_dir
    end
  end
end

