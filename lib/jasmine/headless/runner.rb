require 'fileutils'

require 'coffee-script'
require 'rainbow'

require 'yaml'
require 'erb'
require 'sprockets'

module Jasmine
  module Headless
    class Runner
      JASMINE_DEFAULTS = {
        'spec_files' => [ '**/*[sS]pec.js' ],
        'helpers' => [ 'helpers/**/*.js' ],
        'spec_dir' => 'spec/javascripts',
        'src_dir' => nil,
        'stylesheets' => [],
        'src_files' => [],
        'backtrace' => []
      }

      RUNNER_DIR = File.expand_path('../../../../ext/jasmine-webkit-specrunner', __FILE__)
      RUNNER = File.join(RUNNER_DIR, 'jasmine-webkit-specrunner')

      attr_reader :options

      class << self
        def run(options = {})
          new(options).run
        end
      end

      def initialize(options)
        options = Options.new(options) if !options.kind_of?(Options)

        @options = options
      end

      def template_writer
        @template_writer ||= TemplateWriter.new(self)
      end

      def jasmine_config
        return @jasmine_config if @jasmine_config

        @jasmine_config = JASMINE_DEFAULTS.dup
        jasmine_config_data.each do |key, value|
          @jasmine_config[key] = value if value
        end
        @jasmine_config
      end

      def jasmine_command(*targets)
        command = [ RUNNER ]

        command << "-s #{options[:seed]}"
        command << '-c' if options[:colors]
        command << '-q' if options[:quiet]

        options.file_reporters.each do |reporter, identifier, file|
          command << "-r #{file}"
        end

        command += targets.flatten.collect do |target|
          target = File.expand_path(target)
          target = server_uri + target if options[:use_server]
          target
        end

        command.compact.join(' ')
      end

      def run
        Jasmine::Headless::CacheableAction.enabled = @options[:enable_cache]
        Jasmine::Headless.show_warnings = !@options[:quiet]
        FilesList.reset!

        @_targets = template_writer.write

        run_targets = @_targets.dup

        if run_targets.length == 2
          if (!@options[:full_run] && files_list.filtered?) || files_list.has_spec_outside_scope?
            run_targets.pop
          end
        end

        runner = lambda { system jasmine_command(run_targets) }

        if options[:use_server]
          wrap_in_server(&runner)
        else
          runner.call
        end

        @_status = $?.exitstatus
      ensure
        if @_targets && !runner_filename && (@options[:remove_html_file] || (@_status == 0))
          @_targets.each { |target| FileUtils.rm_f target }
        end
      end

      def runner_filename
        options[:runner_output_filename] || begin
          if (runner_output = jasmine_config['runner_output']) && !runner_output.empty?
            runner_output
          else
            false
          end
        end
      end

      def files_list
        @files_list ||= Jasmine::Headless::FilesList.new(
          :config => jasmine_config,
          :only => options[:files],
          :seed => options[:seed],
          :reporters => options.reporters
        )
      end

      def wrap_in_server
        require 'rack'
        require 'webrick'
        require 'thread'
        require 'net/http'

        server = Thread.new do
          responder = lambda do |env|
            file = Pathname(env['PATH_INFO'])

            if file.file?
              [ 200, { 'Content-Type' => 'text/html' }, [ file.read ] ]
            else
              [ 404, {}, [ 'Not found' ] ]
            end
          end

          Rack::Handler::WEBrick.run(responder, :Port => server_port, :Logger => Logger.new(StringIO.new), :AccessLog => [ nil, nil ])
        end

        while true do
          begin
            Net::HTTP.get(URI(server_uri))
            break
          rescue Errno::ECONNREFUSED => e
          end

          sleep 0.1
        end

        yield

        Thread.kill(server)
      end

      private
      def server_port
        @server_port ||= 21000 + rand(1000)
      end

      def server_interface
        '127.0.0.1'
      end

      def server_uri
        "http://#{server_interface}:#{server_port}"
      end

      def jasmine_config_data
        raise JasmineConfigNotFound.new("Jasmine config not found. I tried #{@options[:jasmine_config]}.") if !File.file?(@options[:jasmine_config])

        YAML.load(ERB.new(File.read(@options[:jasmine_config])).result(binding))
      end
    end
  end
end

