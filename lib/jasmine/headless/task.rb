module Jasmine
  module Headless
    class Task
      include Rake::DSL if defined?(Rake::DSL)

      attr_accessor :colors, :keep_on_error, :jasmine_config, :error_on_console_log

      def initialize(name = 'jasmine:headless')
        @colors = false
        @keep_on_error = false
        @error_on_console_log = true
        @jasmine_config = nil

        yield self if block_given?

        desc 'Run Jasmine specs headlessly'
        task(name) { run_rake_task }
      end

      private
      def run_rake_task
        result = Jasmine::Headless::Runner.run(
                    :colors => colors,
                    :remove_html_file => !@keep_on_error,
                    :jasmine_config => @jasmine_config
                )
        case result
          when 1
            raise Jasmine::Headless::TestFailure
          when 2
            raise Jasmine::Headless::ConsoleLogUsage if @error_on_console_log
          else
            p "Unexpected Jasmine::Headless error code #{result}. If 127, check native extensions have been compiled."
            raise Jasmine::Headless::TestFailure
        end
      end
    end
  end
end
