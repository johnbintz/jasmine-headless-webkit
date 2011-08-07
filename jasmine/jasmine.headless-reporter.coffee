if !jasmine?
  throw new Error("jasmine not laoded!")

class window.HeadlessReporterResult
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
      JHW.printResult(result)
  _findSpecLine: ->
    bestChoice = { accuracy: 0, file: null, lineNumber: null }

    for file, lines of HeadlessReporterResult.specLineNumbers
      index = 0
      lineNumber = 0
      while newLineNumberInfo = lines[@splitName[index]]
        if newLineNumberInfo.length == 0
          lineNumber = newLineNumberInfo[0]
        else
          lastLine = null
          for line in newLineNumberInfo
            lastLine = line
            break if line > lineNumber

          lineNumber = lastLine

        index++

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
  constructor: (@callback = null) ->
    @results = []
    @failedCount = 0
    @length = 0
  reportRunnerResults: (runner) ->
    return if this.hasError()

    for result in @results
      result.print()

    this.callback() if @callback
    JHW.finishSuite((new Date() - @startTime) / 1000.0, @length, @failedCount)
  reportRunnerStarting: (runner) ->
    @startTime = new Date()
  reportSpecResults: (spec) ->
    return if this.hasError()

    results = spec.results()
    @length++
    if results.passed()
      JHW.specPassed()
    else
      JHW.specFailed(spec.getSpecSplitName().join('||'))
      @failedCount++
      failureResult = new HeadlessReporterResult(spec.getFullName(), spec.getSpecSplitName())
      for result in results.getItems()
        if result.type == 'expect' and !result.passed_
          failureResult.addResult(result.message)
      @results.push(failureResult)
  reportSpecStarting: (spec) ->
    if this.hasError()
      spec.finish()
      spec.suite.finish()
  reportSuiteResults: (suite) ->
  hasError: ->
    JHW.hasError()

