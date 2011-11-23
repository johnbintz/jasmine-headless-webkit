module Jasmine::Headless
  class CommandLine
    class << self
      def run!
        require 'coffee-script'
        require 'rainbow'

        begin
          options = Options.from_command_line
          runner = Runner.new(options)

          if options[:do_list]
            FilesList.reset!

            files_list = FilesList.new(:config => runner.jasmine_config)
            files_list.files.each { |file| puts file }
          else
            exit runner.run
          end
        rescue CoffeeScript::CompilationError
          exit 1
        rescue StandardError => e
          $stderr.puts "[%s] %s (%s)" % [ "jasmine-headless-webkit".color(:red), e.message.color(:white), e.class.name.color(:yellow) ]
          $stderr.puts e.backtrace.collect { |line| "  #{line}" }.join("\n")
          exit 1
        end
      end
    end
  end
end

