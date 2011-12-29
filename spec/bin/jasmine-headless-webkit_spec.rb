require 'spec_helper'
require 'tempfile'

describe "jasmine-headless-webkit" do
  let(:report) { 'spec/report.txt' }

  before do
    FileUtils.rm_f report
  end

  after do
    FileUtils.rm_f report
  end

  describe 'files' do
    it 'should list all the files that will be found' do
      files = %x{bin/jasmine-headless-webkit -l -j spec/jasmine/success/success.yml}
      $?.exitstatus.should == 0

      files.lines.to_a.should include(File.expand_path("./spec/jasmine/success/success.js\n"))
      files.lines.to_a.should include(File.expand_path("./spec/jasmine/success/success_spec.js\n"))
    end
  end

  describe 'runner-out' do
    it 'should write out the runner HTML to the specified path and not run the test' do
      runner_path = Tempfile.new('jhw')
      runner_path.close

      system %{bin/jasmine-headless-webkit -j spec/jasmine/success/success.yml --runner-out #{runner_path.path}}

      File.size(runner_path.path).should_not == 0
    end
  end
end

