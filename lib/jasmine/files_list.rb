require 'jasmine-core'
require 'iconv'
require 'time'

module Jasmine
  class FilesList
    attr_reader :files, :filtered_files, :spec_outside_scope

    DEFAULT_FILES = [
      File.join(Jasmine::Core.path, "jasmine.js"),
      File.join(Jasmine::Core.path, "jasmine-html.js"),
      File.expand_path('../../../jasmine/jasmine.headless-reporter.js', __FILE__)
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

        case File.extname(file)
        when '.coffee'
          begin
            %{<script type="text/javascript">#{Jasmine::Headless::CoffeeScriptCache.for(file)}</script>}
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
      }.flatten.compact.reject(&:empty?)
    end

    def spec_filter
      @spec_filter ||= (@options[:only] ? @options[:only].collect { |path| Dir[path] }.flatten : [])
    end

    def use_config!
      @filtered_files = @files.dup

      data = @options[:config].dup
      [ [ 'src_files', 'src_dir' ], [ 'stylesheets', 'src_dir' ], [ 'helpers', 'spec_dir' ], [ 'spec_files', 'spec_dir' ] ].each do |searches, root|
        if data[searches]
          data[searches].flatten.collect do |search|
            path = search
            path = File.join(data[root], path) if data[root]
            found_files = Dir[path] - @files

            @files += found_files

            if searches == 'spec_files'
              @spec_files += spec_filter
            end

            @filtered_files += (if searches == 'spec_files'
              @spec_outside_scope = ((spec_filter | found_files).sort != found_files.sort)
              spec_filter.empty? ? found_files : (spec_filter || found_files)
            else
              found_files
            end)
          end
        end
      end
    end

    def config?
      @options[:config]
    end
  end
end

