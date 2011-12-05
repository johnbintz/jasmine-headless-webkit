module Jasmine::Headless::FileChecker
  def bad_format?(file)
    return if file.nil?
    ::Jasmine::Headless::EXCLUDED_FORMATS.any? {|format| file.include?(".#{format}") }
  end
  
  def alert_bad_format(file)
    puts "[%s] %s: %s" % [ 'Skipping File'.color(:red), file.color(:yellow), "unsupported format".color(:white) ]
  end
end