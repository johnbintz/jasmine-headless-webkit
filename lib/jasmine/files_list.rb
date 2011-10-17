require 'jasmine-core'
require 'time'
require 'multi_json'

module Jasmine
  class FilesList
    attr_reader :files, :spec_files, :filtered_files, :spec_outside_scope

    DEFAULT_FILES = [
      File.join(Jasmine::Core.path, "jasmine.js"),
      File.join(Jasmine::Core.path, "jasmine-html.js"),
      File.join(Jasmine::Core.path, "jasmine.css"),
      Jasmine::Headless.root.join('jasmine/jasmine.headless-reporter.js').to_s,
      Jasmine::Headless.root.join('js-lib/jsDump.js').to_s,
      Jasmine::Headless.root.join('js-lib/beautify-html.js').to_s
    ]

    PLEASE_WAIT_IM_WORKING_TIME = 2

    def initialize(options = {})
      @options = options
      @files = DEFAULT_FILES.dup
      @filtered_files = @files.dup
      @spec_outside_scope = false
      @spec_files = []
      use_config! if config?
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

    private
    def to_html(files)
      alert_time = Time.now + PLEASE_WAIT_IM_WORKING_TIME

      files.collect { |file|
        if alert_time && alert_time < Time.now
          puts "Rebuilding cache, please wait..."
          alert_time = nil
        end

        source = nil

        result = case File.extname(file)
        when '.coffee'
          begin
            cache = Jasmine::Headless::CoffeeScriptCache.new(file)
            source = cache.handle
            if cache.cached?
              %{
                <script type="text/javascript" src="#{cache.cache_file}"></script>S
                <script type="text/javascript">
                  window.CoffeeScriptToFilename = window.CoffeeScriptToFilename || {};
                  window.CoffeeScriptToFilename['#{File.split(cache.cache_file).last}'] = '#{file}';
                </script>
              }
            else
              %{<script type="text/javascript">#{source}</script>}
            end
          rescue CoffeeScript::CompilationError => ne
            puts "[%s] %s: %s" % [ 'coffeescript'.color(:red), file.color(:yellow), ne.message.to_s.color(:white) ]
            raise ne
          rescue StandardError => e
            puts "[%s] Error in compiling one of the followng: %s" % [ 'coffeescript'.color(:red), files.join(' ').color(:yellow) ]
            raise e
          end
        when '.js'
          %{<script type="text/javascript" src="#{file}"></script>}
        when '.css'
          %{<link rel="stylesheet" href="#{file}" type="text/css" />}
        end

        result
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

    def use_config!
      @filtered_files = @files.dup

      data = @options[:config].dup
      [ [ 'src_files', 'src_dir' ], [ 'stylesheets', 'src_dir' ], [ 'vendored_helpers' ], [ 'helpers', 'spec_dir' ], [ 'spec_files', 'spec_dir' ] ].each do |searches, root|
        if data[searches]
          case searches
          when 'vendored_helpers'
            data[searches].each do |name|
              found_files = self.class.find_vendored_asset_path(name)

              @files += found_files
              @filtered_files += found_files
            end
          else
            data[searches].flatten.collect do |search|
              path = search
              path = File.join(data[root], path) if data[root]
              found_files = expanded_dir(path) - @files

              @files += found_files

              if searches == 'spec_files'
                @spec_files += spec_filter.empty? ? found_files : (found_files & spec_filter)
              end

              @filtered_files += begin
                                    if searches == 'spec_files'
                                      @spec_outside_scope = ((spec_filter | found_files).sort != found_files.sort)
                                      spec_filter.empty? ? found_files : (spec_filter || found_files)
                                    else
                                      found_files
                                    end
                                  end
            end
          end
        end
      end
    end

    def config?
      @options[:config]
    end

    def expanded_dir(path)
      Dir[path].collect { |file| File.expand_path(file) }
    end

    def self.find_vendored_asset_path(name)
      require 'rubygems'

      raise StandardError.new("A newer version of Rubygems is required to use vendored assets. Please upgrade.") if !Gem::Specification.respond_to?(:map)
      all_spec_files.find_all { |file| file["vendor/assets/javascripts/#{name}.js"] }
    end

    def self.all_spec_files
      @all_spec_files ||= Gem::Specification.map { |spec| spec.files.find_all { |file|
        file["vendor/assets/javascripts"]
      }.compact.collect { |file| File.join(spec.gem_dir, file) } }.flatten
    end
  end
end

