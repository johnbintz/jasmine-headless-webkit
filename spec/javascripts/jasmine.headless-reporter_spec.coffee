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
