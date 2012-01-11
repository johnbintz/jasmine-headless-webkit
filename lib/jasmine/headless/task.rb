module Jasmine
  module Headless
    class Task
      include Rake::DSL if defined?(Rake::DSL)

      attr_accessor :colors, :keep_on_error, :jasmine_config

      def initialize(name = 'jasmine:headless')
        @colors = false
        @keep_on_error = false
        @jasmine_config = nil

        yield self if block_given?

        desc 'Run Jasmine specs headlessly'
        task(name) { run_rake_task }
      end

      private
      def run_rake_task
        case Jasmine::Headless::Runner.run(
          :colors => colors,
          :remove_html_file => !@keep_on_error,
          :jasmine_config => @jasmine_config
        )
        when 1
          raise Jasmine::Headless::TestFailure
        when 2
          raise Jasmine::Headless::ConsoleLogUsage
        end
      end
    end
  end
end
