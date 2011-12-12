class jasmine.HeadlessFileReporter extends jasmine.HeadlessReporter
  reportRunnerResults: (runner) ->
    super(runner)

    output = "TOTAL||#{@length}||#{@failedCount}||#{this._runtime()}||#{if JHW._hasErrors then "T" else "F"}"

    JHW.report.puts(output)

  reportSpecResults: (spec) ->
    super(spec)

    this._reportSpecResult(spec, {
      success: (results) =>
        JHW.report.puts("PASS||" + spec.getJHWSpecInformation())
      failure: (results) =>
        JHW.report.puts("FAIL||" + spec.getJHWSpecInformation())
    })
