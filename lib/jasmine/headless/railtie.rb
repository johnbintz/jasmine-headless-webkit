require 'jasmine/headless/task'

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
    class Railtie < Rails::Railtie
      rake_tasks do
        Jasmine::Headless::Task.new do |t|
          t.colors = true
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

