Given /^there is no existing "([^"]*)" file$/ do |file|
  FileUtils.rm_rf file
end

