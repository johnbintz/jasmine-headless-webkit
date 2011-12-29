Then /^the exit status should be (\d+)$/ do |exitstatus|
  $?.exitstatus.should == exitstatus.to_i
end
