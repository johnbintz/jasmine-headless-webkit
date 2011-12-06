require 'spec_helper'

describe 'sprockets' do
  it 'should pull in the code via sprockets' do
    files = %x{bin/jasmine-headless-webkit -l -j spec/jasmine/with_sprockets_includes/with_sprockets_includes.yml}
    $?.exitstatus.should == 0
    files.lines.to_a.should contain_in_order_in_file_list(
      'assets/application.js.erb: unsupported format',
      'vendor/assets/javascripts/jquery.js',
      'templates/that.jst.ejs',
      'templates/this.jst',
      'things/jquery.string.js',
      'assets/things/required.js',
      'assets/things/code.js',
      'assets/things/subcode/more_code.js',
      'spec_helper.js',
      'spec/things/code_spec.js'
    )

    files.lines.to_a.any? { |line| line['assets/jquery.string.js: unsupported format'] }.should be_false
  end
end

