RSpec.configure do |c|
  c.mock_with :mocha
end

specrunner = 'ext/jasmine-webkit-specrunner/jasmine-webkit-specrunner'

if !File.file?(specrunner)
  Dir.chdir File.split(specrunner).first do
    system %{ruby extconf.rb}
  end
end

RSpec::Matchers.define :be_a_report_containing do |total, fails, used_console|
  match do |filename|
    parts = File.read(filename).strip.split('/')
    parts.length.should == 4
    parts[0].should == total.to_s
    parts[1].should == fails.to_s
    parts[2].should == (used_console ? "T" : "F")
    true
  end
end
