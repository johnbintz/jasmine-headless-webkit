describe 'jasmine.HeadlessTAPReporter', ->
  beforeEach ->
    @reporter = new jasmine.HeadlessTAPReporter()

  describe '#reportRunnerResults', ->
    it 'should write nothing for nothing', ->
      @reporter.output = []

      @reporter.reportRunnerResults(null)

      expect(@reporter.output[0]).not.toBeDefined()

    it 'should report the length right', ->
      @reporter.output = [ 'test' ]

      @reporter.reportRunnerResults(null)

      expect(@reporter.output[0]).toEqual('1..1')

