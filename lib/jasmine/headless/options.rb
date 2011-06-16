require 'forwardable'

module Jasmine
  module Headless
    class Options
      extend Forwardable

      def_delegators :@options, :[], :[]=

      DEFAULT_OPTIONS = {
        :colors => false,
        :remove_html_file => true,
        :jasmine_config => 'spec/javascripts/support/jasmine.yml',
        :report => false,
        :full_run => true,
        :files => []
      }

      DEFAULTS_FILE = '.jasmine-headless-webkit'
      GLOBAL_DEFAULTS_FILE = File.expand_path("~/#{DEFAULTS_FILE}")

      def self.from_command_line
        options = new
        options.process_command_line_args
        options[:files] = ARGV
        options
      end

      def initialize(opts = {})
        @options = DEFAULT_OPTIONS.dup.merge(opts)
      end

      def process_option(*args)
        opt, arg = args.flatten[0..1]

        case opt
        when '--colors', '-c'
          @options[:colors] = true
        when '--no-colors', '-nc'
          @options[:colors] = false
        when '--keep'
          @options[:remove_html_file] = false
        when '--report'
          @options[:report] = arg
        when '--jasmine-config', '-j'
          @options[:jasmine_config] = arg
        when '--no-full-run'
          @options[:full_run] = false
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
          [ '--keep', GetoptLong::NO_ARGUMENT ],
          [ '--report', GetoptLong::REQUIRED_ARGUMENT ],
          [ '--jasmine-config', '-j', GetoptLong::REQUIRED_ARGUMENT ],
          [ '--no-full-run', GetoptLong::NO_ARGUMENT ]
        )

        command_line_args.each { |*args| process_option(*args) }
      end
    end
  end
end

