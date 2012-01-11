#= require jasmine.HeadlessReporter.ConsoleBase
#
class jasmine.HeadlessReporter.Console extends jasmine.HeadlessReporter.ConsoleBase
  displaySuccess: (spec) =>
    this.print('.'.foreground('green'))

  displayFailure: (spec) =>
    this.print('F'.foreground('red'))
