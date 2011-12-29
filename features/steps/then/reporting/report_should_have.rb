Then /^the report file "(.*)" should have (\d+) total, (\d+) failures?, (no|yes) console usage$/ do |file, total, failures, console_usage|
  report = Jasmine::Headless::Report.load(file)

  report.total.should == total.to_i
  report.failed.should == failures.to_i
  report.has_used_console?.should == (console_usage == 'yes')
end
