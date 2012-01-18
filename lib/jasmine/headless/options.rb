require 'forwardable'
require 'getoptlong'

module Jasmine
  module Headless
    class Options
      extend Forwardable

      def_delegators :@options, :[], :[]=

      DEFAULT_OPTIONS = {
        :colors => false,
        :remove_html_file => true,
        :runner_output_filename => false,
        :jasmine_config => 'spec/javascripts/support/jasmine.yml',
        :do_list => false,
        :full_run => true,
        :enable_cache => true,
        :files => [],
        :reporters => [ [ 'Console' ] ],
        :quiet => false,
        :use_server => false,
        :server_port => nil
      }

      DEFAULTS_FILE = File.join(Dir.pwd, '.jasmine-headless-webkit')
      GLOBAL_DEFAULTS_FILE = File.expand_path('~/.jasmine-headless-webkit')

      REPORT_DEPRECATED_MESSAGE = "--report is deprecated. Use --format HeadlessFileReporter --out <filename>"

      def self.from_command_line
        options = new
        options.process_command_line_args
        options[:files] = ARGV
        options
      end

      def initialize(opts = {})
        @options = DEFAULT_OPTIONS.dup
        srand
        @options[:seed] = rand(10000)
        read_defaults_files

        opts.each { |k, v| @options[k] = v if v }
      end

      def process_option(*args)
        opt, arg = args.flatten[0..1]

        case opt
        when '--colors', '-c'
          @options[:colors] = true
        when '--no-colors', '-nc'
          @options[:colors] = false
        when '--cache'
          @options[:enable_cache] = true
        when '--no-cache'
          @options[:enable_cache] = false
        when '--keep'
          @options[:remove_html_file] = false
        when '--report'
          warn REPORT_DEPRECATED_MESSAGE

          add_reporter('File', arg)
          add_reporter('Console')
        when '--runner-out'
          @options[:runner_output_filename] = arg
        when '--jasmine-config', '-j'
          @options[:jasmine_config] = arg
        when '--no-full-run'
          @options[:full_run] = false
        when '--list', '-l'
          @options[:do_list] = true
        when '--quiet', '-q'
          @options[:quiet] = true
        when '--seed'
          @options[:seed] = arg.to_i
        when '--format', '-f'
          add_reporter(arg)
        when '--use-server'
          @options[:use_server] = true
        when '--server-port'
          @options[:server_port] = arg.to_i
        when '--out'
          add_reporter_file(arg)
        when '-h', '--help'
          print_help

          exit
        end
      end

      def read_defaults_files
        [ GLOBAL_DEFAULTS_FILE, DEFAULTS_FILE ].each do |file|
          if File.file?(file)
            File.readlines(file).collect { |line| line.strip.split(' ', 2) }.each { |*args| process_option(*args) }
          end
        end
      end

      def process_command_line_args
        command_line_args = GetoptLong.new(
          [ '--colors', '-c', GetoptLong::NO_ARGUMENT ],
          [ '--no-colors', GetoptLong::NO_ARGUMENT ],
          [ '--cache', GetoptLong::NO_ARGUMENT ],
          [ '--no-cache', GetoptLong::NO_ARGUMENT ],
          [ '--keep', GetoptLong::NO_ARGUMENT ],
          [ '--runner-out', GetoptLong::REQUIRED_ARGUMENT ],
          [ '--report', GetoptLong::REQUIRED_ARGUMENT ],
          [ '--jasmine-config', '-j', GetoptLong::REQUIRED_ARGUMENT ],
          [ '--no-full-run', GetoptLong::NO_ARGUMENT ],
          [ '--list', '-l', GetoptLong::NO_ARGUMENT ],
          [ '--seed', GetoptLong::REQUIRED_ARGUMENT ],
          [ '--format', '-f', GetoptLong::REQUIRED_ARGUMENT ],
          [ '--out', GetoptLong::REQUIRED_ARGUMENT ],
          [ '--use-server', GetoptLong::NO_ARGUMENT ],
          [ '--server-port', GetoptLong::REQUIRED_ARGUMENT ],
          [ '-h', '--help', GetoptLong::NO_ARGUMENT ],
          [ '-q', '--quiet', GetoptLong::NO_ARGUMENT ]
        )

        command_line_args.each { |*args| process_option(*args) }
      end

      def reporters
        file_index = 0

        @options[:reporters].collect do |reporter, file|
          output = [ reporter ]
          if file
            output << "report:#{file_index}"
            output << file
            file_index += 1
          else
            output << "stdout"
          end

          output
        end
      end

      def file_reporters
        reporters.find_all { |reporter| reporter[1]["report:"] }
      end

      private
      def add_reporter(name, file = nil)
        if !@added_reporter
          @options[:reporters] = []
          @added_reporter = true
        end

        if (parts = name.split(':')).length == 2
          name, file = parts
        end

        @options[:reporters] << [ name ]

        add_reporter_file(file) if file
      end

      def add_reporter_file(file)
        @options[:reporters].last << file
      end

      def print_help
        options = [
          [ '-c, --colors', 'Enable colors (default: disabled)' ],
          [ '-nc, --no-colors', 'Disable colors' ],
          [ '--cache', 'Enable cache (default: enabled)' ],
          [ '--no-cache', 'Disable cache' ],
          [ '--keep', 'Keep runner files on failure' ],
          [ '--runner-out <filename>', 'Write runner to specified filename' ],
          [ '-j, --jasmine-config <config file>', 'Jasmine Yaml config to use' ],
          [ '--no-full-run', 'Do not perform a full spec run after a successful targeted spec run' ],
          [ '--use-server', 'Load tests from an HTTP server instead of from filesystem' ],
          [ '-l, --list', 'List files in the order they will be required' ],
          [ '--seed <seed>', 'Random order seed for spec file ordering' ],
          [ '-f, --format <reporter<:filename>>', 'Specify an output reporter and possibly output filename' ],
          [ '--out <filename>', 'Specify output filename for last defined reporter' ],
          [ '-q, --quiet', "Silence most non-test related warnings" ],
          [ '-h, --help', "You're looking at it" ]
        ]

        longest_length = options.collect(&:first).collect(&:length).max

        puts <<-HELP
Usage: #{$0} [ options ] [ spec files ]

Options:
#{options.collect { |option, description| "  #{option.ljust(longest_length)}  #{description}" }.join("\n")}

Available reporters:
  Console  Write out spec results to the console in a progress format (default)
  Verbose  Write out spec results to the console in a verbose format
  File     Write spec results in jasmine-headless-webkit ReportFile format
  Tap      Write spec results in TAP format

Add reporters to the jasmine.HeadlessReporter object to access them
  (ex: jasmine.HeadlessReporter.Teamcity for the Teamcity reporter)
HELP
      end
    end
  end
end

