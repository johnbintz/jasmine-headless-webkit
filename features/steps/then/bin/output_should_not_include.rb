Then /^the output should not include "([^"]*)"$/ do |string|
  @output.should_not include(string)
end

