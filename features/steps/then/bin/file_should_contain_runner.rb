Then /^the file "([^"]*)" should contain a JHW runner$/ do |file|
  File.read(file).should include('jasmine.HeadlessReporter')
end

