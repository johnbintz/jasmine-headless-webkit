When /^I run `(.*)`$/ do |command|
  @output = `#{command}`
end

