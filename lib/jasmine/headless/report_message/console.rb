module Jasmine::Headless::ReportMessage
  class Console
    class << self
      def new_from_parts(parts)
        new(parts.first)
      end
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

