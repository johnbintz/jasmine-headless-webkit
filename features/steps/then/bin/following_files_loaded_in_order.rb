Then /^the following files should be loaded in order:$/ do |table|
  files = table.raw.flatten

  @output.lines.collect(&:strip).each do |line|
    files.shift if line[files.first]
  end

  files.should be_empty
end

