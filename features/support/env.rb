require 'jasmine-headless-webkit'

After do
  FileUtils.rm_f 'spec/report.txt'
  FileUtils.rm_f 'spec/runner.html'
end

