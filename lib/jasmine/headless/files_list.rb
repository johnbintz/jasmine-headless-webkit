require 'jasmine-core'
require 'time'
require 'multi_json'
require 'set'
require 'sprockets'
require 'sprockets/engines'

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

        # register haml-sprockets if it's available...
        %w{haml-sprockets}.each do |library|
          begin
            require library
          rescue LoadError
          end
        end

        # ...and unregister ones we don't want/need
        Sprockets.instance_eval do
          %w{less sass scss erb str}.each do |extension|
            @engines.delete(".#{extension}")
          end

          register_engine '.coffee', Jasmine::Headless::CoffeeTemplate
          register_engine '.js', Jasmine::Headless::JSTemplate
          register_engine '.css', Jasmine::Headless::CSSTemplate
        end
      end

      def default_files
        %w{jasmine.js jasmine-html jasmine.css jasmine-extensions intense headless_reporter_result jasmine.HeadlessConsoleReporter jsDump beautify-html}
      end
    end

    PLEASE_WAIT_IM_WORKING_TIME = 2

    attr_reader :required_files, :potential_files_to_filter

    def initialize(options = {})
      @options = options

      @required_files = []
      @potential_files_to_filter = []

      self.class.default_files.each do |file|
        @required_files << sprockets_environment.find_asset(file, :bundle => false)
      end

      use_config! if config?
    end

    def files
      required_files.collect { |file| file.send(:required_assets).collect { |asset| asset.pathname.to_s } }.flatten.uniq
    end

    def spec_files
      filter_for_requested_specs(
        files.find_all { |file| spec_dir.any? { |dir| file[dir] } }
      )
    end

    def filtered_files
      filter_for_requested_specs(files)
    end

    def search_paths
      return @search_paths if @search_paths

      @search_paths = [ Jasmine::Core.path ]
      @search_paths += src_dir.collect { |dir| File.expand_path(dir) }
      @search_paths += spec_dir.collect { |dir| File.expand_path(dir) }
      @search_paths += self.class.vendor_asset_paths

      @search_paths
    end

    def sprockets_environment
      return @sprockets_environment if @sprockets_environment

      @sprockets_environment = Sprockets::Environment.new
      search_paths.each do |path|
        @sprockets_environment.append_path(path)
      end

      @sprockets_environment
    end

    def path_searcher
      @path_searcher ||= PathSearcher.new(self)
    end

    def has_spec_outside_scope?
      if is_outside_scope = !spec_filter.empty?
        is_outside_scope = spec_dir.any? do |dir|
          spec_file_searches.any? do |search|
            !spec_files.any? { |file| 
              File.fnmatch?(File.join(dir, search), file)
            }
          end
        end
      end

      is_outside_scope
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
      @spec_file_line_numbers ||= Hash[spec_files.collect { |file|
        if File.exist?(file)
          if !(lines = Jasmine::Headless::SpecFileAnalyzer.for(file)).empty?
            [ file, lines ]
          end
        else
          nil
        end
      }.compact]
    end

    private
    def to_html(files)
      alert_time = Time.now + PLEASE_WAIT_IM_WORKING_TIME

      files.collect do |file|
        if alert_time && alert_time < Time.now
          puts "Rebuilding cache, please wait..."
          alert_time = nil
        end

        sprockets_environment.find_asset(file, :bundle => false).to_s
      end.flatten.compact.reject(&:empty?)
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
      @config = @options[:config].dup
      @searches = {}
      @potential_files_to_filter = []

      %w{src_files stylesheets helpers spec_files}.each do |type|
        if data = @config[type]
          dirs = send(SEARCH_ROOTS[type])

          add_files(@searches[type] = data.flatten, type, dirs)
        end
      end

      filtered_required_files = []

      @required_files.each do |file|
        if !filtered_required_files.any? { |other_file| other_file.logical_path == file.logical_path }
          filtered_required_files << file
        end
      end

      @required_files = filtered_required_files
    end

    def add_files(patterns, type, dirs)
      dirs.each do |dir|
        patterns.each do |search|
          search = File.expand_path(File.join(dir, search))

          Dir[search].find_all { |file| file[extension_filter] }.each do |path|
            add_path(path, type) if File.file?(path)
          end
        end
      end

      if type == 'spec_files'
        spec_filter.each { |path| add_path(path, type) }
      end
    end

    def config?
      @options[:config]
    end

    def expanded_dir(path)
      Dir[path].collect { |file| File.expand_path(file) }.find_all { |path| File.file?(path) && path[extension_filter] }
    end

    def extension_filter
      %r{(#{(%w{.js .css} + Sprockets.engine_extensions).join('|')})$}
    end

    def add_path(path, type)
      asset = sprockets_environment.find_asset(path, :bundle => false)

      @required_files << asset

      if type == 'spec_files'
        @potential_files_to_filter << path
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

    def spec_file_searches
      @searches['spec_files']
    end

    def config_dir_or_pwd(dir)
      found_dir = Dir.pwd

      if @options[:config]
        found_dir = @options[:config][dir] || found_dir
      end

      [ found_dir ].flatten.collect { |dir| File.expand_path(dir) }
    end

    def filter_for_requested_specs(files)
      files.find_all do |file|
        if potential_files_to_filter.include?(file)
          spec_filter.empty? || spec_filter.any? { |pattern| File.fnmatch?(pattern, file) }
        else
          true
        end
      end
    end
  end
end
