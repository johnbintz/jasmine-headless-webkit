(function() {
  if (!(typeof jasmine !== "undefined" && jasmine !== null)) {
    throw new Error("jasmine not laoded!");
  }
  jasmine.HeadlessReporter = (function() {
    function HeadlessReporter(callback) {
      this.callback = callback != null ? callback : null;
      this.results = [];
      this.failedCount = 0;
      this.length = 0;
      this._hasError = false;
    }
    HeadlessReporter.prototype.reportRunnerResults = function(runner) {
      var result, resultLine, runtime, _i, _len, _ref;
      if (this.hasError()) {
        return;
      }
      if (this.callback) {
        this.callback();
      }
      runtime = (new Date() - this.startTime) / 1000.0;
      JHW.stdout.print("\n");
      resultLine = this._formatResultLine(runtime);
      if (this.failedCount === 0) {
        JHW.stdout.puts(("PASS: " + resultLine).foreground('green'));
      } else {
        JHW.stdout.puts(("FAIL: " + resultLine).foreground('red'));
      }
      _ref = this.results;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        result = _ref[_i];
        result.print();
      }
      return JHW.finishSuite();
    };
    HeadlessReporter.prototype.reportRunnerStarting = function(runner) {
      this.startTime = new Date();
      return JHW.stdout.puts("Running Jasmine specs...");
    };
    HeadlessReporter.prototype.reportSpecResults = function(spec) {
      var failureResult, foundLine, result, results, testCount, _i, _len, _ref;
      if (this.hasError()) {
        return;
      }
      results = spec.results();
      this.length++;
      if (results.passed()) {
        JHW.stdout.print('.'.foreground('green'));
        return JHW.report.puts("PASS||" + spec.getJHWSpecInformation());
      } else {
        JHW.stdout.print('F'.foreground('red'));
        JHW.report.puts("FAIL||" + spec.getJHWSpecInformation());
        this.failedCount++;
        failureResult = new HeadlessReporterResult(spec.getFullName(), spec.getSpecSplitName());
        testCount = 1;
        _ref = results.getItems();
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          result = _ref[_i];
          if (result.type === 'expect' && !result.passed_) {
            if (foundLine = result.expectations[testCount - 1]) {
              result.line = foundLine[0], result.lineNumber = foundLine[1];
            }
            failureResult.addResult(result);
          }
          testCount += 1;
        }
        return this.results.push(failureResult);
      }
    };
    HeadlessReporter.prototype.reportSpecStarting = function(spec) {
      if (this.hasError()) {
        spec.finish();
        return spec.suite.finish();
      }
    };
    HeadlessReporter.prototype.reportSuiteResults = function(suite) {};
    HeadlessReporter.prototype.hasError = function() {
      return JHW._hasErrors;
    };
    HeadlessReporter.prototype._formatResultLine = function(runtime) {
      var line;
      line = [];
      line.push(this.length);
      line.push((this.length === 1 ? "test" : "tests") + ',');
      line.push(this.failedCount);
      line.push((this.failedCount === 1 ? "failure" : "failures") + ',');
      line.push(runtime);
      line.push((runtime === 1.0 ? "sec" : "secs") + '.');
      return line.join(' ');
    };
    return HeadlessReporter;
  })();
}).call(this);
