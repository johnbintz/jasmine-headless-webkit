describe 'jasmine.HeadlessReporter', ->
  reporter = null

  beforeEach ->
    reporter = new jasmine.HeadlessReporter()

  it 'should stop running specs if there are errors reported', ->
    # otherwise it gets really confusing!

    suite = { finish: -> null }
    spec = new jasmine.Spec("env", suite, "test")

    spyOn(reporter, 'hasError').andReturn(true)
    spyOn(spec, 'finish')
    spyOn(suite, 'finish')

    reporter.reportSpecStarting(spec)

    expect(spec.finish).toHaveBeenCalled()
    expect(suite.finish).toHaveBeenCalled()

  describe '#reportRunnerStarting', ->
    it 'should start getting time', ->
      expect(reporter.startTime).not.toBeDefined()
      reporter.reportRunnerStarting("runner")
      expect(reporter.startTime).toBeDefined()

