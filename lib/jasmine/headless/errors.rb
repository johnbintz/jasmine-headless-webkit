module Jasmine
  module Headless
    class NoRunnerError < StandardError
      def message
        "The jasmine-headless-webkit specrunner (jasmine-webkit-specrunner) could not be found! Try reinstalling the gem."
      end
    end
  end
end

