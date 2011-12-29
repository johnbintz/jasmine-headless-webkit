if !jasmine?
  throw new Error("jasmine not loaded!")

class jasmine.HeadlessReporter
  constructor: (@outputTarget = null) ->
    @results = []
    @failedCount = 0
    @length = 0
    @timer = null

  hasError: ->
    JHW._hasErrors

  reportSpecStarting: (spec) ->
    if this.hasError()
      spec.finish()
      spec.suite.finish()

  reportSuiteResults: (suite) ->

  reportRunnerStarting: (runner) ->
    @startTime = new Date()

  reportRunnerResults: (runner) ->
    return if this.hasError()

    if @failedCount != 0
      JHW.hasSpecFailure()

    JHW.finishSuite()

    if window.JHW
      window.onbeforeunload = null

  reportSpecResults: (spec) ->
    return if this.hasError()
    JHW.ping()

  _reportSpecResult: (spec, options) ->
    results = spec.results()

    @length++

    if results.passed()
      options.success(results, spec)
    else
      @failedCount++
      options.failure(results, spec)

  _runtime: ->
    (new Date() - @startTime) / 1000.0

  print: (output) =>
    JHW.print(@outputTarget, output)

  puts: (output) =>
    JHW.print(@outputTarget, output + "\n")

