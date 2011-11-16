module Jasmine::Headless
  class TestFile
    attr_reader :path

    def initialize(path)
      @path = path
    end
  end
end
