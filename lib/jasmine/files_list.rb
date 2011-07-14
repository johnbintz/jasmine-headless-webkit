begin
  require 'jasmine'
rescue NameError => e
  if e.message['ActiveSupport::Concern']
    $stderr.puts "[%s] %s (%s)" % [ "jasmine-gem".color(:red), e.message.color(:white), e.class.name.color(:yellow) ]
    $stderr.puts "#{'Jasmine'.color(:red)} believes Rails 3 is available. Try using #{'Bundler'.color(:green)} and running via #{'bundle exec'.color(:green)}."
  else
    raise e
  end
end

module Jasmine
  class FilesList
    attr_reader :files, :filtered_files, :spec_outside_scope

    DEFAULT_FILES = [
      File.join(Jasmine::Core.path, "jasmine.js"),
      File.join(Jasmine::Core.path, "jasmine-html.js"),
      File.expand_path('../../../jasmine/jasmine.headless-reporter.js', __FILE__)
    ]

    class << self
      def get_spec_line_numbers(file)
        line_numbers = {}

        file.lines.each_with_index.each { |line, index|
          if description = line[%r{(describe|context|it)[( ]*(["'])(.*)\2}, 3]
            (line_numbers[description] ||= []) << (index + 1)
          end
        }

        line_numbers
      end
    end

    def initialize(options = {})
      @options = options
      @files = DEFAULT_FILES.dup
      @filtered_files = @files.dup
      @spec_outside_scope = false
      @spec_files = []
      use_config! if config?

      @code_for_file = {}
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
          if !(lines = self.class.get_spec_line_numbers(File.read(file))).empty?
            [ file, lines ]
          end
        else
          nil
        end
      }.compact]
    end

    private
    def to_html(files)
      coffeescript_run = []

      files.collect { |file|
        next @code_for_file[file] if @code_for_file[file]

        coffeescript_run << file if (ext = File.extname(file)) == '.coffee'
          
        output = []
        if (files.last == file or ext != '.coffee') and !coffeescript_run.empty?
          output << ensure_coffeescript_run!(coffeescript_run)
        end

        if ext != '.coffee'
          output << case File.extname(file)
          when '.js'
            %{<script type="text/javascript" src="#{file}"></script>}
          when '.css'
            %{<link rel="stylesheet" href="#{file}" type="text/css" />}
          end
        end

        @code_for_file[file] = output if output.length == 1

        output
      }.flatten.reject(&:empty?)
    end

    def ensure_coffeescript_run!(files)
      data = StringIO.new
      files.each { |file| data << File.read(file) << "\n" }
      data.rewind

      %{<script type="text/javascript">#{CoffeeScript.compile(data)}</script>}
    rescue CoffeeScript::CompilationError => e
      files.each do |file|
        begin
          CoffeeScript.compile(fh = File.open(file))
        rescue CoffeeScript::CompilationError => ne
          puts "[%s] %s: %s" % [ 'coffeescript'.color(:red), file.color(:yellow), ne.message.to_s.color(:white) ]
          raise ne
        ensure
          fh.close
        end
      end
    rescue StandardError => e
      puts "[%s] Error in compiling one of the followng: %s" % [ 'coffeescript'.color(:red), files.join(' ').color(:yellow) ]
      raise e
    ensure
      files.clear
    end

    def spec_filter
      @spec_filter ||= (@options[:only] ? @options[:only].collect { |path| Dir[path] }.flatten : [])
    end

    def use_config!
      @filtered_files = @files.dup

      data = @options[:config].dup
      [ [ 'src_files', 'src_dir' ], [ 'stylesheets', 'src_dir' ], [ 'helpers', 'spec_dir' ], [ 'spec_files', 'spec_dir' ] ].each do |searches, root|
        if data[searches]
          data[searches].collect do |search|
            path = search
            path = File.join(data[root], path) if data[root]
            found_files = Dir[path] - @files

            @files += found_files

            if searches == 'spec_files'
              @spec_files = @files + spec_filter
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

