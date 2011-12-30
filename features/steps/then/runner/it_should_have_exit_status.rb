Then /^the runner should have an exit status of (\d+)$/ do |exit_status|
  @result.should == exit_status.to_i
end
