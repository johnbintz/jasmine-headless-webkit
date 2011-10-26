describe 'HeadlessReporterResult', ->
  result = null
  name = "name"
  splitName = "splitName"
  message = 'message'

  beforeEach ->
    result = new HeadlessReporterResult(name, splitName)

  describe '#addResult', ->
    it 'should add a message', ->
      result.addResult(message)

      expect(result.results).toEqual([ message ])
