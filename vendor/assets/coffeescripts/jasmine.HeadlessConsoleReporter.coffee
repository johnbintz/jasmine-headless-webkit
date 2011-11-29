if !jasmine?
  throw new Error("jasmine not loaded!")

class jasmine.HeadlessConsoleReporter
  constructor: (@callback = null) ->
    @results = []
    @failedCount = 0
    @length = 0
    @timer = null
    @position = 0
    @positions = "|/-\\"

  reportRunnerResults: (runner) ->
    return if this.hasError()

    runtime = (new Date() - @startTime) / 1000.0

    JHW.stdout.print("\n")

    resultLine = this._formatResultLine(runtime)

    if @failedCount == 0
      JHW.stdout.puts("PASS: #{resultLine}".foreground('green'))
    else
      JHW.stdout.puts("FAIL: #{resultLine}".foreground('red'))
      JHW.hasSpecFailure()

    output = "TOTAL||#{@length}||#{@failedCount}||#{runtime}||#{if JHW._hasErrors then "T" else "F"}"

    JHW.report.puts(output)

    for result in @results
      JHW.stdout.puts(result.toString())

    if window.JHW
      window.onbeforeunload = null

    JHW.finishSuite()

  reportRunnerStarting: (runner) ->
    @startTime = new Date()
    JHW.stdout.puts("\nRunning Jasmine specs...".bright()) if !this.hasError()

  reportSpecResults: (spec) ->
    return if this.hasError()
    JHW.ping()

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

  reportSpecWaiting: ->
    runner = null

    if !@timer
      @timer = true
      first = true

      runner = =>
        @timer = setTimeout(
          =>
            if @timer
              JHW.stdout.print(Intense.moveBack()) if !first
              JHW.stdout.print(@positions.substr(@position, 1).foreground('yellow'))
              @position += 1
              @position %= @positions.length
              first = false
              runner()
          , 750
        )
      runner()

  reportSpecRunning: ->
    if @timer
      clearTimeout(@timer)
      @timer = null
      JHW.stdout.print(Intense.moveBack())

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

