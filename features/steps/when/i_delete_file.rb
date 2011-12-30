When /^I delete the file "([^"]*)"$/ do |file|
  FileUtils.rm_f(file)
end
