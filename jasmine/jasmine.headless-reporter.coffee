if !jasmine?
  throw new Error("jasmine not laoded!")

class HeadlessReporterResult
  constructor: (name) ->
    @name = name
    @results = []
  addResult: (message) ->
    @results.push(message)
  print: ->
    JHW.printName(@name)
    for result in @results
      do (result) =>
        JHW.printResult(result)

class jasmine.HeadlessReporter
  constructor: ->
    @results = []
    @failedCount = 0
    @length = 0
  reportRunnerResults: (runner) ->
    for result in @results
      do (result) =>
        result.print()

    JHW.finishSuite((new Date() - @startTime) / 1000.0, @length, @failedCount)
  reportRunnerStarting: (runner) ->
    @startTime = new Date()
  reportSpecResults: (spec) ->
    results = spec.results()
    @length++
    if results.passed()
      JHW.specPassed()
    else
      JHW.specFailed()
      @failedCount++
      failureResult = new HeadlessReporterResult(spec.getFullName())
      for result in results.getItems()
        do (result) =>
          if result.type == 'expect' and !result.passed_
            failureResult.addResult(result.message)
      @results.push(failureResult)
  reportSpecStarting: (spec) ->
  reportSuiteResults: (suite) ->
