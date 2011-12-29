Then /^the command to run the runner should include the report file "([^"]*)"$/ do |file|
  @runner.jasmine_command.should include("-r #{file}")
end

