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
    expect(HeadlessReporterResult.findSpecLine([ 'name', 'of', 'test' ]).lineNumber).toEqual(3)
    expect(HeadlessReporterResult.findSpecLine([ 'other', 'of', 'test' ]).lineNumber).toEqual(10)

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

describe 'jasmine.Suite.prototype.getSuiteSplitName', ->
  it 'should flatten the description', ->
    suite = new jasmine.Suite({});
    suite.description = "hello\ngoodbye\n";
    expect(suite.getSuiteSplitName()).toEqual([ "hello goodbye " ])

  it 'should not fail on missing description', ->
    suite = new jasmine.Suite({});
    suite.description = 1;
    expect(suite.getSuiteSplitName()).toEqual([ "1" ])

describe 'jasmine.Spec.prototype.getSuiteSplitName', ->
  it 'should flatten the description', ->
    spec = new jasmine.Spec({}, {});
    spec.suite = {
      getSuiteSplitName: -> []
    }
    spec.description = "hello\ngoodbye\n";
    expect(spec.getSpecSplitName()).toEqual([ "hello goodbye " ])

  it 'should not fail on missing description', ->
    spec = new jasmine.Spec({}, {});
    spec.suite = {
      getSuiteSplitName: -> []
    }
    spec.description = 1
    expect(spec.getSpecSplitName()).toEqual([ "1" ])

