require 'jasmine/headless/runner'
require 'jasmine/headless/options'
require 'getoptlong'

module Jasmine
  module Headless
    class CLI
      def self.run
        Runner.run(Options.from_command_line)
      rescue NoRunnerError
        puts "The Qt WebKit widget is not compiled! Try re-installing this gem."
        1
      end
    end
  end
end

