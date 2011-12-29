Then /^the command to run the runner should not include a report file$/ do
  @runner.jasmine_command.should_not include('-r')
end
