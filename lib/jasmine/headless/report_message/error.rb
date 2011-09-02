module Jasmine::Headless::ReportMessage
  class Error
    class << self
      def new_from_parts(parts)
        new(*parts)
      end
    end

    attr_reader :message, :file_info

    def initialize(message, file_info)
      @message, @file_info = message, file_info
    end

    def ==(other)
      self.message == other.message && self.file_info == other.file_info
    end
  end
end

