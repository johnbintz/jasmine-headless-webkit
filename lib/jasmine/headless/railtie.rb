module Jasmine
  module Headless
    class Railtie < Rails::Railtie
      rake_tasks do
        Jasmine::Headless::Task.new do |t|
          t.colors = true
        end
      end
    end
  end
end

