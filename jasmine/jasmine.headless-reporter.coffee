if !jasmine?
  throw new Error("jasmine not laoded!")

# The reporter itself.
class jasmine.HeadlessReporter
  constructor: (@callback = null) ->
    @results = []
    @failedCount = 0
    @length = 0

  reportRunnerResults: (runner) ->
    return if this.hasError()

    this.callback() if @callback

    runtime = (new Date() - @startTime) / 1000.0

    JHW.stdout.print("\n")

    resultLine = this._formatResultLine(runtime)

    if @failedCount == 0
      JHW.stdout.puts("PASS: #{resultLine}".foreground('green'))
    else
      JHW.stdout.puts("FAIL: #{resultLine}".foreground('red'))

    result.print() for result in @results

    JHW.finishSuite()

  reportRunnerStarting: (runner) ->
    @startTime = new Date()
    JHW.stdout.puts("Running Jasmine specs...")

  reportSpecResults: (spec) ->
    return if this.hasError()

    results = spec.results()
    @length++
    if results.passed()
      JHW.stdout.print('.'.foreground('green'))
      JHW.report.puts("PASS||" + spec.getJHWSpecInformation())
    else
      JHW.stdout.print('F'.foreground('red'))
      JHW.report.puts("FAIL||" + spec.getJHWSpecInformation())
      @failedCount++
      failureResult = new HeadlessReporterResult(spec.getFullName(), spec.getSpecSplitName())
      testCount = 1
      for result in results.getItems()
        if result.type == 'expect' and !result.passed_
          if foundLine = result.expectations[testCount - 1]
            [ result.line, result.lineNumber ] = foundLine
          failureResult.addResult(result)
        testCount += 1
      @results.push(failureResult)

  reportSpecStarting: (spec) ->
    if this.hasError()
      spec.finish()
      spec.suite.finish()

  reportSuiteResults: (suite) ->
  hasError: ->
    JHW._hasErrors

  _formatResultLine: (runtime) ->
    line = []
    line.push(@length)
    line.push((if @length == 1 then "test" else "tests") + ',')

    line.push(@failedCount)
    line.push((if @failedCount == 1 then "failure" else "failures") + ',')

    line.push(runtime)
    line.push((if runtime == 1.0 then "sec" else "secs") + '.')

    line.join(' ')

