Given /^I have the following runner options:$/ do |string|
  @options = YAML.load(string)
end
