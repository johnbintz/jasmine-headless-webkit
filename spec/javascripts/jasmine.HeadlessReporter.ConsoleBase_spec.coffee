describe 'jasmine.HeadlessReporter.ConsoleBase', ->
  reporter = null

  beforeEach ->
    reporter = new jasmine.HeadlessReporter.ConsoleBase()

  describe '#formatResultLine', ->
    context 'length = 1', ->
      it 'should format', ->
        reporter.length = 1
        expect(reporter.formatResultLine(0)).toMatch(/test,/)

    context 'length != 1', ->
      it 'should format', ->
        reporter.length = 2
        expect(reporter.formatResultLine(0)).toMatch(/tests,/)

    context 'failedCount = 1', ->
      it 'should format', ->
        reporter.failedCount = 1
        expect(reporter.formatResultLine(0)).toMatch(/failure,/)

    context 'failedCount != 1', ->
      it 'should format', ->
        reporter.failedCount = 0
        expect(reporter.formatResultLine(0)).toMatch(/failures,/)

    context 'runtime = 1', ->
      it 'should format', ->
        expect(reporter.formatResultLine(1)).toMatch(/sec./)

    context 'runtime != 1', ->
      it 'should format', ->
        expect(reporter.formatResultLine(0)).toMatch(/secs./)

