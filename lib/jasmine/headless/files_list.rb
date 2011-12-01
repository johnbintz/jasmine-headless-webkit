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

        raise StandardError.new("A newer version of Rubygems is required to use vendored assets. Please upgrade.") if !Gem::Specification.respond_to?(:each)

        @vendor_asset_paths = []

        Gem::Specification.each do |spec|
          path = File.join(spec.gem_dir, 'vendor/assets/javascripts')

          @vendor_asset_paths << path if File.directory?(path)
        end

        @vendor_asset_paths
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
          register_engine '.jst', Jasmine::Headless::JSTTemplate
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

      Kernel.srand(@options[:seed]) if @options[:seed]

      @required_files = UniqueAssetList.new
      @potential_files_to_filter = []

      self.class.default_files.each do |file|
        @required_files << sprockets_environment.find_asset(file, :bundle => false)
      end

      use_config! if config?
    end

    def files
      required_files.flatten.collect { |asset| asset.pathname.to_s }.uniq
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
      @search_paths += self.class.vendor_asset_paths
      @search_paths += src_dir.collect { |dir| File.expand_path(dir) }
      @search_paths += spec_dir.collect { |dir| File.expand_path(dir) }

      @search_paths
    end

    def sprockets_environment
      return @sprockets_environment if @sprockets_environment

      @sprockets_environment = Sprockets::Environment.new
      search_paths.each { |path| @sprockets_environment.append_path(path) }

      @sprockets_environment.unregister_postprocessor('application/javascript', Sprockets::SafetyColons)
      @sprockets_environment
    end

    def has_spec_outside_scope?
      if is_outside_scope = !spec_filter.empty?
        is_outside_scope = spec_dir.any? do |dir|
          spec_file_searches.any? do |search|
            !spec_files.any? { |file| File.fnmatch?(File.join(dir, search), file) }
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

        sprockets_environment.find_asset(file, :bundle => false).body
      end.compact.reject(&:empty?)
    end

    def spec_filter
      @spec_filter ||= (@options[:only] && @options[:only].collect { |path| expanded_dir(path) }.flatten) || []
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
          add_files(@searches[type] = data.flatten, type, send(SEARCH_ROOTS[type]))
        end
      end
    end

    def add_files(patterns, type, dirs)
      dirs.product(patterns).each do |search|
        files = expanded_dir(File.join(*search))

        files.sort! { |a, b| Kernel.rand(3) - 1 } if type == 'spec_files'

        files.each do |path|
          add_path(path, type)
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
      Dir[path].find_all { |file| file[extension_filter] }.collect { |file| File.expand_path(file) }.find_all { |path| File.file?(path) }
    end

    def extension_filter
      %r{(#{(%w{.js .css} + Sprockets.engine_extensions).join('|')})$}
    end

    def add_path(path, type)
      asset = sprockets_environment.find_asset(path)

      @required_files << asset

      if type == 'spec_files'
        @potential_files_to_filter << path
      end
    end

    def src_dir
      @src_dir ||= config_dir_or_pwd('src_dir')
    end

    def spec_dir
      @spec_dir ||= config_dir_or_pwd('spec_dir')
    end

    def spec_file_searches
      @searches['spec_files']
    end

    def config_dir_or_pwd(dir)
      found_dir = (@options[:config] && @options[:config][dir]) || Dir.pwd

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
