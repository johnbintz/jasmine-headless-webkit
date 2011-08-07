describe 'HeadlessReporterResult', ->
  beforeEach ->
    HeadlessReporterResult.specLineNumbers = {
      'one': {
        'name': [ 1 ],
        'of': [ 2, 9 ],
        'test': [ 3, 10 ],
        'other': [ 7 ]
      }
    }
  it 'should find the best spec lines', ->
    result = new HeadlessReporterResult('test', [ 'name', 'of', 'test' ])
    expect(result._findSpecLine().lineNumber).toEqual(3)

    result = new HeadlessReporterResult('test', [ 'other', 'of', 'test' ])
    expect(result._findSpecLine().lineNumber).toEqual(10)

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

