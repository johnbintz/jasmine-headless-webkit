if !jasmine?
  throw new Error("jasmine not laoded!")

if window.JHW
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
    if specLineInfo.file
      parts.push("#{specLineInfo.file}:#{specLineInfo.lineNumber}")
    else
      parts.push('')
    parts.join("||")

  jasmine.Spec.prototype.finishCallback = ->
    JHW.ping()
    this.env.reporter.reportSpecResults(this)

  jasmine.Spec.prototype.fail = (e) ->
    e = JHW.createCoffeeScriptFileException(e)

    expectationResult = new jasmine.ExpectationResult({
      passed: false,
      message: if e then jasmine.util.formatException(e) else 'Exception',
      trace: { stack: e.stack }
    })
    @results_.addResult(expectationResult)

    this.env.reporter.reportException(e)

  jasmine.NestedResults.isValidSpecLine = (line) ->
    line.match(/^\s*expect/) != null || line.match(/^\s*return\s*expect/) != null

  jasmine.NestedResults.parseFunction = (func) ->
    lines = []
    lineCount = 0
    for line in func.split("\n")
      if jasmine.NestedResults.isValidSpecLine(line)
        line = line.replace(/^\s*/, '').replace(/\s*$/, '').replace(/^return\s*/, '')
        lines.push([line, lineCount])
      lineCount += 1
    lines

  jasmine.NestedResults.parseAndStore = (func) ->
    if !jasmine.NestedResults.ParsedFunctions[func]
      jasmine.NestedResults.ParsedFunctions[func] = jasmine.NestedResults.parseFunction(func)
    jasmine.NestedResults.ParsedFunctions[func]

  jasmine.NestedResults.ParsedFunctions = []

  if !jasmine.WaitsBlock.prototype._execute
    jasmine.WaitsBlock.prototype._execute = jasmine.WaitsBlock.prototype.execute
    jasmine.WaitsForBlock.prototype._execute = jasmine.WaitsForBlock.prototype.execute

    pauseAndRun = (onComplete) ->
      JHW.timerPause()
      jasmine.getEnv().reporter.reportSpecWaiting()

      this._execute ->
        jasmine.getEnv().reporter.reportSpecRunning()
        JHW.timerDone()
        onComplete()

    jasmine.WaitsBlock.prototype.execute = pauseAndRun
    jasmine.WaitsForBlock.prototype.execute = pauseAndRun

    jasmine.NestedResults.prototype.addResult_ = jasmine.NestedResults.prototype.addResult
    jasmine.NestedResults.prototype.addResult = (result) ->
      result.expectations = []
      # always three up?

      result.expectations = jasmine.NestedResults.parseAndStore(arguments.callee.caller.caller.caller.toString())

      this.addResult_(result)

    for method in [ "reportSpecWaiting", "reportSpecRunning", "reportException" ]
      generator = (method) ->
        (args...) ->
          for reporter in @subReporters_
            if reporter[method]?
              reporter[method](args...)

      jasmine.MultiReporter.prototype[method] = generator(method)

