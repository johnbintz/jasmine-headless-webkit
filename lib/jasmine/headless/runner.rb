require 'jasmine/headless/errors'
require 'jasmine/headless/options'

require 'fileutils'

require 'coffee-script'
require 'rainbow'

require 'jasmine/files_list'
require 'jasmine/template_writer'

require 'yaml'

module Jasmine
  module Headless
    class Runner
      JASMINE_DEFAULTS = {
        'spec_files' => [ '**/*[sS]pec.js' ],
        'helpers' => [ 'helpers/**/*.js' ],
        'spec_dir' => 'spec/javascripts',
        'src_dir' => nil,
        'stylesheets' => [],
        'src_files' => []
      }

      RUNNER_DIR = File.expand_path('../../../../ext/jasmine-webkit-specrunner', __FILE__)
      RUNNER = File.join(RUNNER_DIR, 'jasmine-webkit-specrunner')

      attr_reader :options

      def self.run(options = {})
        options = Options.new(options) if !options.kind_of?(Options)
        new(options).run
      end

      def initialize(options)
        if !File.file?(RUNNER)
          $stderr.puts "No runner found, attempting to compile..."
          Dir.chdir RUNNER_DIR do
            system %{ruby extconf.rb}
          end
          raise NoRunnerError if !File.file?(RUNNER)
        end

        @options = options
      end

      def jasmine_config
        raise JasmineConfigNotFound.new("Jasmine config not found. I tried #{@options[:jasmine_config]}.") if !File.file?(@options[:jasmine_config])

        @jasmine_config ||= JASMINE_DEFAULTS.dup.merge(YAML.load_file(@options[:jasmine_config]))
      end

      def jasmine_command(*targets)
        [
          RUNNER,
          @options[:colors] ? '-c' : nil,
          @options[:report] ? "-r #{@options[:report]}" : nil,
          *targets
        ].compact.join(" ")
      end

      def run
        Jasmine::Headless::CoffeeScriptCache.enabled = @options[:enable_cache]

        files_list = Jasmine::FilesList.new(
          :config => jasmine_config,
          :only => @options[:files]
        )

        targets = Jasmine::TemplateWriter.write!(files_list)
        run_targets = targets.dup
        run_targets.pop if (!@options[:full_run] && files_list.filtered?) || files_list.has_spec_outside_scope?

        system jasmine_command(run_targets)
        status = $?.exitstatus

        if @options[:remove_html_file] || (status == 0)
          targets.each { |target| FileUtils.rm_f target }
        end

        status
      end
    end
  end
end

