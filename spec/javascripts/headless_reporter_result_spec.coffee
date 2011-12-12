describe 'HeadlessReporterResult', ->
  result = null
  name = "name"
  splitName = "splitName"
  message = 'message'

  context 'no lines', ->
    beforeEach ->
      result = new HeadlessReporterResult(name, splitName)

    describe '#addResult', ->
      it 'should add a message', ->
        result.addResult(message)

        expect(result.results).toEqual([ message ])

  context 'with lines', ->
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

