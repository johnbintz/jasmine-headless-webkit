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
    parts(filename).length.should == 4
    parts[0].should == total.to_s
    parts[1].should == fails.to_s
    parts[2].should == (used_console ? "T" : "F")
    true
  end

  failure_message_for_should do |filename|
    parts(filename)
    "expected #{filename} to be a report containing (#{total}, #{fails}, #{used_console.inspect}), instead it contained (#{parts[0]}, #{parts[1]}, #{(parts[2] == "T").inspect})"
  end

  def parts(filename = nil)
    @parts ||= File.read(filename).strip.split('/')
  end
end

