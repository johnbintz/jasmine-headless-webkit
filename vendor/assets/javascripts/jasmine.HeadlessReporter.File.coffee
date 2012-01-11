#= require jasmine.HeadlessReporter
#
class jasmine.HeadlessReporter.File extends jasmine.HeadlessReporter
  reportRunnerResults: (runner) ->
    super(runner)

    output = "TOTAL||#{@length}||#{@failedCount}||#{this._runtime()}||#{if JHW._hasErrors then "T" else "F"}"

    this.puts(output)
    this.puts("SEED||#{JHW.getSeed()}")

  consoleLogUsed: (msg) ->
    this.puts("CONSOLE||#{msg}")

  reportSpecResults: (spec) ->
    super(spec)

    this._reportSpecResult(spec, {
      success: (results) =>
        this.puts("PASS||" + spec.getJHWSpecInformation())
      failure: (results) =>
        this.puts("FAIL||" + spec.getJHWSpecInformation())
    })

