require 'jasmine-core'
require 'time'
require 'multi_json'
require 'set'
require 'sprockets'
require 'sprockets/engines'
require 'sprockets-vendor_gems'

module Jasmine::Headless
  class FilesList
    include FileChecker

    class << self
      def asset_paths
        @asset_paths ||= Sprockets.find_gem_vendor_paths(:for => 'javascripts')
      end

      def reset!
        @asset_paths = nil
        @registered_engines = {}

        # register haml-sprockets and handlebars_assets if it's available...
        %w{haml-sprockets handlebars_assets}.each do |library|
          begin
            require library
          rescue LoadError
          end
        end

        if ENV['JHW_ENV']
          begin
            require 'bundler'

            Bundler.require(ENV['JHW_ENV'].to_sym)
          rescue LoadError
          end
        end

        @sprockets_environment = nil
      end

      def registered_engines
        @registered_engines ||= {}
      end

      def register_engine(file_extension, template_class)
        registered_engines[file_extension] = template_class
      end

      def register_engines!
        registered_engines.each do |file_extension, template_class|
          Sprockets.register_engine file_extension, template_class
        end
      end

      def default_files
        %w{jasmine.js jasmine-html jasmine.css jasmine-extensions
           intense headless_reporter_result jasmine.HeadlessReporter
           jasmine.HeadlessReporter.ConsoleBase
           jsDump beautify-html}
      end

      def extension_filter
        extensions = (%w{.js .css} + Sprockets.engine_extensions)

        %r{(#{extensions.join('|')})$}
      end
    end

    PLEASE_WAIT_IM_WORKING_TIME = 2

    attr_reader :options, :required_files, :potential_files_to_filter

    def initialize(options = {})
      @options = options

      Kernel.srand(options[:seed]) if options[:seed]

      @required_files = UniqueAssetList.new
      @potential_files_to_filter = []

      register_engines!

      load_initial_assets

      use_config if config?
    end

    def register_engines!
      begin
        require spec_helper
      rescue LoadError
      end
      self.class.register_engines!
    end

    def load_initial_assets
      self.class.default_files.each do |file|
        begin
          add_path(file)
        rescue InvalidUniqueAsset => e
          raise StandardError.new("Not an asset: #{file}")
        end
      end

      (options[:reporters] || []).each do |reporter, identifier, file|
        add_path("jasmine.HeadlessReporter.#{reporter}")
      end
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

      @search_paths = [ Jasmine::Core.path, Jasmine::Headless.root.join('vendor/assets/javascripts').to_s ]
      @search_paths += self.class.asset_paths
      @search_paths += src_dir.collect { |dir| File.expand_path(dir) }
      @search_paths += asset_paths.collect { |dir| File.expand_path(dir) }
      @search_paths += spec_dir.collect { |dir| File.expand_path(dir) }

      @search_paths.uniq!
      @search_paths
    end

    def sprockets_environment
      return @sprockets_environment if @sprockets_environment

      @sprockets_environment = Sprockets::Environment.new
      search_paths.each { |path| @sprockets_environment.append_path(path) }

      @sprockets_environment.unregister_postprocessor('application/javascript', Sprockets::SafetyColons)

      # ...and unregister ones we don't want/need
      @sprockets_environment.instance_eval do
        EXCLUDED_FORMATS.each do |extension|
          register_engine ".#{extension}", Jasmine::Headless::NilTemplate
        end

        register_engine '.coffee', Jasmine::Headless::CoffeeTemplate
        register_engine '.em', Jasmine::Headless::EmberScriptTemplate
        register_engine '.js', Jasmine::Headless::JSTemplate
        register_engine '.css', Jasmine::Headless::CSSTemplate
        register_engine '.jst', Jasmine::Headless::JSTTemplate
      end

      @sprockets_environment
    end

    def has_spec_outside_scope?
      if is_outside_scope = !spec_filter.empty?
        is_outside_scope = spec_dir.any? do |dir|
          spec_file_searches.any? do |search|
            !spec_files.any? do |file|
              target = File.join(dir, search)
              File.fnmatch?(target, file) || File.fnmatch?(target.gsub(%{^**/}, ''), file)
            end
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

    def use_config
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
      patterns.each do |pattern|
        dirs.collect { |dir| expanded_dir(File.join(dir, pattern)) }.each do |files|
          files.sort! { |a, b| Kernel.rand(3) - 1 } if type == 'spec_files'

          files.each do |path|
            add_path(path, type)
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
      file_list = Dir.glob(path).sort
      file_list.find_all { |file|
        file[extension_filter] && !alert_if_bad_format?(file)
      }.collect {
        |file| File.expand_path(file)
      }.find_all {
        |path| File.file?(path)
      }
    end

    def extension_filter
      self.class.extension_filter
    end

    def add_path(path, type = nil)
      asset = sprockets_environment.find_asset(path)

      @required_files << asset

      if type == 'spec_files'
        @potential_files_to_filter << path
      end
    end

    def src_dir
      @src_dir ||= config_dir_or_pwd('src_dir') + asset_paths
    end

    def spec_dir
      @spec_dir ||= config_dir_or_pwd('spec_dir')
    end

    def asset_paths
      @asset_paths ||= config_dir('asset_paths')
    end

    def spec_file_searches
      @searches['spec_files']
    end

    def config_dir_or_pwd(dir)
      if (found = config_dir(dir)).empty?
        found = [ Dir.pwd ]
      end

      found
    end

    def config_dir(dir)
      [ @options[:config] && @options[:config][dir] ].flatten.compact.collect { |dir| File.expand_path(dir) }
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

    def spec_helper
      File.join(spec_dir, "helpers", "spec_helper")
    end
  end
end

module Jasmine::Headless
  extend self

  def register_engine(file_extension, template_class)
    Jasmine::Headless::FilesList.register_engine(file_extension, template_class)
  end
end
