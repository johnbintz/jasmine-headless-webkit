require 'jasmine-core'
require 'time'
require 'multi_json'
require 'set'
require 'sprockets/directive_processor'

module Jasmine::Headless
  class FilesList
    attr_reader :spec_outside_scope

    class << self
      def find_vendored_asset_paths(*names)
        require 'rubygems'

        raise StandardError.new("A newer version of Rubygems is required to use vendored assets. Please upgrade.") if !Gem::Specification.respond_to?(:map)
        all_spec_files.find_all do |file|
          names.any? { |name| file["/#{name}.js"] }
        end
      end

      def all_spec_files
        @all_spec_files ||= Gem::Specification.map { |spec| spec.files.find_all { |file|
          file["vendor/assets/javascripts"]
        }.compact.collect { |file| File.join(spec.gem_dir, file) } }.flatten
      end
    end

    DEFAULT_FILES = 
      %w{jasmine.js jasmine-html.js jasmine.css}.collect { |name| File.join(Jasmine::Core.path, name) } +
      %w{jasmine-extensions intense headless_reporter_result jasmine.HeadlessConsoleReporter jsDump beautify-html}.collect { |name|
        Jasmine::Headless.root.join("vendor/assets/javascripts/#{name}.js").to_s
      }

    PLEASE_WAIT_IM_WORKING_TIME = 2

    def initialize(options = {})
      @options = options
      @files = Set.new(DEFAULT_FILES.dup)
      @filtered_files = @files.dup
      @spec_outside_scope = false
      @spec_files = Set.new
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

    def add_dependencies(file)
      if File.file?(file)
        processor = Sprockets::DirectiveProcessor.new(file)
        processor.directives.each do |line, type, name|
          case type
          when 'require'
            find_vendored(name)
          end
        end
      end
    end

    private
    def to_html(files)
      alert_time = Time.now + PLEASE_WAIT_IM_WORKING_TIME

      files.collect { |file|
        if alert_time && alert_time < Time.now
          puts "Rebuilding cache, please wait..."
          alert_time = nil
        end

        Jasmine::Headless::TestFile.new(file).to_html
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

      %w{src_files stylesheets vendored_helpers helpers spec_files}.each do |searches|
        if data = @config[searches]
          if self.respond_to?("add_#{searches}_files", true)
            send("add_#{searches}_files", data.flatten)
          else
            add_files(data.flatten, searches)
          end
        end
      end
    end

    def add_vendored_helpers_files(searches)
      searches.each do |name|
        self.class.find_vendored_asset_path(name).each do |file|
          add_file(file)
        end
      end
    end

    def add_files(searches, type)
      searches.each do |search|
        path = search
        path = File.join(@config[SEARCH_ROOTS[type]], path) if @config[SEARCH_ROOTS[type]]
        found_files = expanded_dir(path) - files

        found_files.each do |file|
          type == 'spec_files' ? add_spec_file(file) : add_file(file)
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
      Dir[path].collect { |file| File.expand_path(file) }
    end

    def add_file(file)
      add_dependencies(file)

      @files << file
      @filtered_files << file
    end

    def add_spec_file(file)
      add_dependencies(file)

      if !@files.include?(file)
        @files << file

        if include_spec_file?(file)
          @filtered_files << file
          @spec_files << file if spec_filter.empty? || spec_filter.include?(file)
        end

        true
      end
    end

    def include_spec_file?(file)
      spec_filter.empty? || spec_filter.include?(file)
    end

  end
end

