require 'forwardable'

module Jasmine::Headless
  class Report
    extend Forwardable

    def_delegators :report, :length, :[]
    def_delegators :last_total, :total, :failed, :time

    class << self
      def load(file)
        new(file).process
      end
    end

    attr_reader :file, :report

    def initialize(file)
      @file = file
    end

    def process
      last_message = nil
      @report = File.readlines(file).collect do |line|
        type, *parts = line.split('||', -1)

        if !(report_klass = report_class_for(type))
          if last_message.kind_of?(Jasmine::Headless::ReportMessage::Console)
            last_message.message << "\n"
            last_message.message << line.strip
          end
        else
          parts.last.strip!

          last_message = report_klass.new_from_parts(parts)
        end
      end
      self
    end

    def has_used_console?
      @report.any? { |entry| entry.kind_of?(Jasmine::Headless::ReportMessage::Console) }
    end

    def has_failed_on?(statement)
      @report.any? { |entry| 
        if entry.kind_of?(Jasmine::Headless::ReportMessage::Fail)
          entry.statement == statement
        end
      }
    end

    def valid?
      last_total != nil
    end

    def failed_files
      @report.find_all { |entry| 
        entry.kind_of?(Jasmine::Headless::ReportMessage::Fail)
      }.collect(&:filename).uniq.compact
    end

    def seed
      if seed = report.find { |entry| entry.respond_to?(:seed) }
        seed.seed
      end
    end

    private
    def last_total
      @report.reverse.find { |entry| entry.respond_to?(:total) }
    end

    def report_class_for(type)
      if constant = ReportMessage.constants.find { |k| k.to_s.downcase == type.downcase }
        ReportMessage.const_get(constant)
      end
    end
  end
end

