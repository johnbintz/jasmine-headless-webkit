module Jasmine::Headless::ReportMessage
  class Spec
    def self.new_from_parts(parts)
      file_info = parts.pop

      new(parts.join(' '), file_info)
    end

    attr_reader :statement, :file_info

    def initialize(statement, file_info)
      @statement, @file_info = statement, file_info
    end

    def ==(other)
      self.statement == other.statement && self.file_info == other.file_info
    end

    def filename
      if name = file_info.split(":").first
        name
      else
        nil
      end
    end
  end
end

