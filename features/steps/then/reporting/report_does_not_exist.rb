Then /^the report file "([^"]*)" should not exist$/ do |file|
  File.file?(file).should be_false
end

