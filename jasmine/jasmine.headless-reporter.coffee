if !jasmine?
  throw new Error("jasmine not laoded!")

class HeadlessReporterResult
  constructor: (@name, @splitName) ->
    @results = []
  addResult: (message) ->
    @results.push(message)
  print: ->
    output = @name
    bestChoice = this._findSpecLine()
    output += " (#{bestChoice.file}:#{bestChoice.lineNumber})" if bestChoice.file

    JHW.printName(output)
    for result in @results
      do (result) =>
        JHW.printResult(result)
  _findSpecLine: ->
    bestChoice = { accuracy: 0, file: null, lineNumber: null }

    for file, lines of SPEC_LINE_NUMBERS
      index = 0
      while newLineNumber = lines[@splitName[index]]
        index++
        lineNumber = newLineNumber

      if index > bestChoice.accuracy
        bestChoice = { accuracy: index, file: file, lineNumber: lineNumber }
    
    bestChoice

jasmine.Suite.prototype.getSuiteSplitName = ->
  parts = if @parentSuite then @parentSuite.getSuiteSplitName() else []
  parts.push(@description)
  parts

jasmine.Spec.prototype.getSpecSplitName = ->
  parts = @suite.getSuiteSplitName()
  parts.push(@description)
  parts

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
      JHW.specFailed(spec.getSpecSplitName().join('||'))
      @failedCount++
      failureResult = new HeadlessReporterResult(spec.getFullName(), spec.getSpecSplitName())
      for result in results.getItems()
        do (result) =>
          if result.type == 'expect' and !result.passed_
            failureResult.addResult(result.message)
      @results.push(failureResult)
  reportSpecStarting: (spec) ->
  reportSuiteResults: (suite) ->
