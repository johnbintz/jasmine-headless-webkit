Then /^the report file "([^"]*)" should exist$/ do |file|
  File.file?(file).should be_true
end
