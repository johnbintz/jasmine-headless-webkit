#= require jasmine.HeadlessReporter.js
#
class jasmine.HeadlessConsoleReporter extends jasmine.HeadlessReporter
  constructor: (@callback = null) ->
    super(@callback)

    @position = 0
    @positions = "|/-\\"

  reportRunnerResults: (runner) ->
    super()

    JHW.stdout.print("\n")

    resultLine = this.formatResultLine(this._runtime())

    if @failedCount == 0
      JHW.stdout.puts("PASS: #{resultLine}".foreground('green'))
    else
      JHW.stdout.puts("FAIL: #{resultLine}".foreground('red'))

    for result in @results
      JHW.stdout.puts(result.toString())

    if window.JHW
      window.onbeforeunload = null

  reportRunnerStarting: (runner) ->
    super(runner)
    JHW.stdout.puts("\nRunning Jasmine specs...".bright()) if !this.hasError()

  reportSpecResults: (spec) ->
    super(spec)

    this._reportSpecResult(spec, {
      success: (results) =>
        JHW.stdout.print('.'.foreground('green'))
      failure: (results) =>
        JHW.stdout.print('F'.foreground('red'))

        failureResult = new HeadlessReporterResult(spec.getFullName(), spec.getSpecSplitName())
        testCount = 1

        for result in results.getItems()
          if result.type == 'expect' and !result.passed_
            if foundLine = result.expectations[testCount - 1]
              [ result.line, result.lineNumber ] = foundLine
            failureResult.addResult(result)
          testCount += 1
        @results.push(failureResult)
    })

  reportSpecWaiting: ->
    if !@timer
      @timer = true
      @first = true

      this._waitRunner()

  reportSpecRunning: ->
    if @timer
      clearTimeout(@timer)
      @timer = null
      JHW.stdout.print(Intense.moveBack())

  formatResultLine: (runtime) ->
    line = []
    line.push(@length)
    line.push((if @length == 1 then "test" else "tests") + ',')

    line.push(@failedCount)
    line.push((if @failedCount == 1 then "failure" else "failures") + ',')

    line.push(runtime)
    line.push((if runtime == 1.0 then "sec" else "secs") + '.')

    line.join(' ')

  _waitRunner: =>
    @timer = setTimeout(
      =>
        if @timer
          JHW.stdout.print(Intense.moveBack()) if !@first
          JHW.stdout.print(@positions.substr(@position, 1).foreground('yellow'))
          @position += 1
          @position %= @positions.length
          @first = false
          this._waitRunner()
      , 750
    )
