if !jasmine?
  throw new Error("jasmine not laoded!")

# Jasmine extensions
getSplitName = (parts) ->
  parts.push(String(@description).replace(/[\n\r]/g, ' '))
  parts

jasmine.Suite.prototype.getSuiteSplitName = ->
  this.getSplitName(if @parentSuite then @parentSuite.getSuiteSplitName() else [])

jasmine.Spec.prototype.getSpecSplitName = ->
  this.getSplitName(@suite.getSuiteSplitName())

jasmine.Suite.prototype.getSplitName = getSplitName
jasmine.Spec.prototype.getSplitName = getSplitName

jasmine.Spec.prototype.getJHWSpecInformation = ->
  parts = this.getSpecSplitName()
  specLineInfo = HeadlessReporterResult.findSpecLine(parts)
  parts.push("#{specLineInfo.file}:#{specLineInfo.lineNumber}")
  parts.join("||")

if !jasmine.WaitsBlock.prototype._execute
  jasmine.WaitsBlock.prototype._execute = jasmine.WaitsBlock.prototype.execute
  jasmine.WaitsForBlock.prototype._execute = jasmine.WaitsForBlock.prototype.execute

  pauseAndRun = (onComplete) ->
    JHW.timerPause()
    this._execute ->
      JHW.timerDone()
      onComplete()

  jasmine.WaitsBlock.prototype.execute = pauseAndRun
  jasmine.WaitsForBlock.prototype.execute = pauseAndRun

# Try to get the line number of a failed spec
class window.HeadlessReporterResult
  constructor: (@name, @splitName) ->
    @results = []
  addResult: (message) ->
    @results.push(message)
  print: ->
    output = @name
    bestChoice = HeadlessReporterResult.findSpecLine(@splitName)
    output += " (#{bestChoice.file}:#{bestChoice.lineNumber})" if bestChoice.file

    JHW.printName(output)
    for result in @results
      JHW.printResult(result)
  @findSpecLine: (splitName) ->
    bestChoice = { accuracy: 0, file: null, lineNumber: null }

    for file, lines of HeadlessReporterResult.specLineNumbers
      index = 0
      lineNumber = 0
      while newLineNumberInfo = lines[splitName[index]]
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

# The reporter itself.
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
      JHW.specPassed(spec.getJHWSpecInformation())
    else
      JHW.specFailed(spec.getJHWSpecInformation())
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

