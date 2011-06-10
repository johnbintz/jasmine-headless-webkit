
# Add files and commands to this file, like the example:
#   watch('file/path') { `command(s)` }
#

guard 'shell' do
  watch(%r{ext/jasmine-webkit-specrunner/specrunner.cpp}) { compile }
end
# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec', :version => 2, :all_on_start => false do
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/(.+)\.rb})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^bin/(.+)})     { |m| "spec/bin/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { "spec" }
end

def compile
  system %{cd ext/jasmine-webkit-specrunner && ruby extconf.rb}
end

compile

guard 'coffeescript', :input => 'jasmine'
