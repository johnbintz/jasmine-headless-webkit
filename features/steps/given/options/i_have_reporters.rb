Given /^I have the following reporters:$/ do |table|
  @options[:reporters] = []

  table.hashes.each do |hash|
    reporter = [ hash['Name'] ]
    reporter << hash['File'] if !hash['File'].empty?

    @options[:reporters] << reporter
  end
end
