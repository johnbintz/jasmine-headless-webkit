Then /^the report file "([^"]*)" should have seed (\d+)$/ do |file, seed|
  report = Jasmine::Headless::Report.load(file)
  report.seed.should == seed.to_i
end
