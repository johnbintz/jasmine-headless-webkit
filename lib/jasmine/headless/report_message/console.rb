module Jasmine::Headless::ReportMessage
  class Console
    def self.new_from_parts(parts)
      new(parts.first)
    end

    attr_reader :message

    def initialize(message)
      @message = message
    end

    def ==(other)
      self.message == other.message
    end
  end
end

