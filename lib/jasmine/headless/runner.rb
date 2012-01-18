require 'fileutils'

require 'coffee-script'
require 'rainbow'

require 'yaml'
require 'erb'
require 'sprockets'

module Jasmine
  module Headless
    class IndexHandler
      class << self
        attr_accessor :index
      end

      def initialize(app)
        @app = app
      end

      def call(env)
        if env['PATH_INFO'] == '/'
          return [ 302, { 'Location' => self.class.index }, [ 'Redirecting...' ] ]
        end

        @app.call(env)
      end
    end

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

      def self.run(options = {})
        new(options).run
      end

      def self.server_port
        return @server_port if @server_port

        require 'socket'

        count = 100
        begin
          port = select_server_port

          socket = TCPSocket.new(server_interface, port)
          socket.close

          count -= 1

          raise "Could not create server port after 100 attempts!" if count == 0
        rescue Errno::ECONNREFUSED
          @server_port = port

          break
        ensure
          begin
            socket.close if socket
          rescue IOError
          end
        end while true

        @server_port
      end

      def self.server_port=(port)
        @server_port = port
      end

      def self.select_server_port
        21000 + rand(10000)
      end

      def self.server_interface
        '127.0.0.1'
      end

      def self.server_uri
        "http://#{server_interface}:#{server_port}"
      end

      def self.server_spec_path
        self.server_uri + '/__JHW__/'
      end

      def self.ensure_server(options)
        return if @server

        require 'webrick'
        require 'thread'
        require 'rack'
        require 'net/http'

        port = server_port

        @server = Thread.new do
          Jasmine::Headless.warn "Powering up!"

          app = Rack::Builder.new do
            use IndexHandler

            map '/__JHW__' do
              run Rack::File.new(Dir.pwd)
            end

            map '/' do
              run Rack::File.new('/')
            end
          end

          Rack::Handler::WEBrick.run(
            app,
            :Port => port,
            :Logger => Logger.new(StringIO.new),
            :AccessLog => [
              [ StringIO.new, WEBrick::AccessLog::COMMON_LOG_FORMAT ],
              [ StringIO.new, WEBrick::AccessLog::REFERER_LOG_FORMAT ]
            ]
          )
        end

        while true do
          begin
            Net::HTTP.get(URI(server_uri))
            break
          rescue Errno::ECONNREFUSED => e
          end

          sleep 0.1
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

        command += targets
        command.compact.join(' ')
      end

      def run
        Jasmine::Headless::CacheableAction.enabled = @options[:enable_cache]
        Jasmine::Headless.show_warnings = !@options[:quiet]
        FilesList.reset!

        self.class.server_port = options[:server_port]

        @_targets = template_writer.write

        run_targets = absolute_run_targets(@_targets.dup)

        if run_targets.length == 2
          if (!@options[:full_run] && files_list.filtered?) || files_list.has_spec_outside_scope?
            run_targets.pop
          end
        end

        runner = lambda { system jasmine_command(run_targets) }

        if options[:use_server]
          wrap_in_server(run_targets, &runner)
        else
          runner.call
        end

        @_status = $?.exitstatus
      ensure
        if @_targets && !runner_filename && (@options[:remove_html_file] || (@_status == 0))
          @_targets.each { |target| FileUtils.rm_f target }
        end
      end

      def absolute_run_targets(targets)
        targets.flatten.collect do |target|
          if options[:use_server]
            target = self.class.server_spec_path + target
          else
            target = "file://" + File.expand_path(target)
          end
          target
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

      def wrap_in_server(run_targets)
        self.class.ensure_server(options)
        IndexHandler.index = run_targets.last

        Jasmine::Headless.warn "HTTP powered specs! Located at #{run_targets.join(' ')}"

        yield
      end

      private
      def jasmine_config_data
        raise JasmineConfigNotFound.new("Jasmine config not found. I tried #{@options[:jasmine_config]}.") if !File.file?(@options[:jasmine_config])

        YAML.load(ERB.new(File.read(@options[:jasmine_config])).result(binding))
      end
    end
  end
end

