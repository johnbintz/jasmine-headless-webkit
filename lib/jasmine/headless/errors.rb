module Jasmine
  module Headless
    class NoRunnerError < StandardError
      def message
        "The jasmine-headless-webkit specrunner (jasmine-webkit-specrunner) could not be found! Try reinstalling the gem."
      end
    end

    class TestFailure < StandardError; end
    class ConsoleLogUsage < StandardError ; end
  end
end

