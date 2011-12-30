Then /^the output should include "([^"]*)"$/ do |string|
  @output.should include(string)
end
