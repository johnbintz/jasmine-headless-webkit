#= require jasmine.HeadlessReporter.ConsoleBase
#
class jasmine.HeadlessReporter.Verbose extends jasmine.HeadlessReporter.ConsoleBase
  displaySuccess: (spec) =>
    this.displaySpec(spec, 'green')

  displayFailure: (spec) =>
    this.displaySpec(spec, 'red')

  displaySpec: (spec, color) =>
    currentLastNames = (@lastNames || []).slice(0)
    @lastNames = spec.getSpecSplitName()

    this.puts(this.indentSpec(@lastNames, currentLastNames, color).join("\n"))

  indentSpec: (current, last, color) =>
    last = last.slice(0)

    output = []

    indent = ''
    for name in current
      output.push(indent + name.foreground(color)) if last.shift() != name
      indent += '  '

    output
