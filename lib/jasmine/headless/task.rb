require 'jasmine/headless/runner'

module Digest
  class JasmineTest
    def self.file(file)
      new
    end

    def file(file)
      self
    end
    
    def hexdigest
      'test'
    end

    def update(prefix)
      self
    end
  end
end

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
        task name do
          Jasmine::Headless::Runner.run(
            :colors => colors, 
            :remove_html_file => !@keep_on_error, 
            :jasmine_config => @jasmine_config
          )
        end

        if Rails.version >= "3.1.0"
          desc 'Force generate static assets without an MD5 hash, all assets end with -test.<ext>'
          task 'assets:precompile:for_testing' => :environment do
            Rails.application.assets.digest_class = Digest::JasmineTest

            Rake::Task['assets:precompile'].invoke
          end
        end
      end
    end
  end
end
