module Jasmine
  module Headless
    class Task
      begin
        include Rake::DSL
      rescue NameError
        # never mind
      end

      attr_accessor :colors, :keep_on_error, :jasmine_config

      def initialize(name = 'jasmine:headless')
        @colors = false
        @keep_on_error = false
        @jasmine_config = nil

        yield self if block_given?

        desc 'Run Jasmine specs headlessly'
        task name do
          system %{jasmine-headless-webkit #{@colors ? "-c" : "--no-colors"} #{@keep_on_error ? "--keep" : ""} #{@jasmine_config ? "-j #{@jasmine_config}" : ""}}
        end
      end
    end
  end
end
