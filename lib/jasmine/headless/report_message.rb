module Jasmine::Headless
  module ReportMessage
    autoload :Spec, 'jasmine/headless/report_message/spec'
    autoload :Pass, 'jasmine/headless/report_message/pass'
    autoload :Fail, 'jasmine/headless/report_message/fail'
    autoload :Console, 'jasmine/headless/report_message/console'
    autoload :Error, 'jasmine/headless/report_message/error'
    autoload :Total, 'jasmine/headless/report_message/total'
  end
end

