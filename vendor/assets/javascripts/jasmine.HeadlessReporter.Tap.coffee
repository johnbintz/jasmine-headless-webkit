#= require jasmine.HeadlessReporter

class jasmine.HeadlessReporter.Tap extends jasmine.HeadlessReporter
  constructor: (@outputTarget = null) ->
    super(@outputTarget)

    @output = []

  reportRunnerResults: (runner) ->
    super(runner)

    @output.unshift("1..#{@output.length}") if @output.length > 0

    this.puts(@output.join("\n"))

  reportSpecResults: (spec) ->
    super(spec)

    index = @output.length + 1
    description = spec.getSpecSplitName().join(' ')

    this._reportSpecResult(spec, {
      success: (results) =>
        @output.push("ok #{index} #{description}")
      failure: (results) =>
        @output.push("not ok #{index} #{description}")
    })

