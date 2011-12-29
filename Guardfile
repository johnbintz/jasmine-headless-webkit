
# Add files and commands to this file, like the example:
#   watch('file/path') { `command(s)` }
#

guard 'coffeescript', :input => 'vendor/assets/coffeescripts', :output => 'vendor/assets/javascripts'

guard 'shell' do
  watch(%r{ext/jasmine-webkit-specrunner/.*\.(cpp|h|pro|pri)}) { |m|
    if !m[0]['moc_']
      compile 
    end
  }
end
# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec', :version => 2, :all_on_start => false do
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/(.+)\.rb})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^bin/(.+)})     { |m| "spec/bin/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { "spec" }
end

guard 'cucumber', :cli => '-r features --format pretty' do
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$})          { 'features' }
  watch(%r{^features/steps/(.+)_steps\.rb$}) { 'features' }
end

guard 'jasmine-headless-webkit', :all_on_start => false do
  watch(%r{^spec/javascripts/.+_spec\.coffee})
  watch(%r{^jasmine/(.+)\.coffee$}) { |m| "spec/javascripts/#{m[1]}_spec.coffee" }
end

def compile
  system %{cd ext/jasmine-webkit-specrunner && ruby extconf.rb}
end

compile

