
  if (!(typeof jasmine !== "undefined" && jasmine !== null)) {
    throw new Error("jasmine not loaded!");
  }

  jasmine.HeadlessConsoleReporter = (function() {

    function HeadlessConsoleReporter(callback) {
      this.callback = callback != null ? callback : null;
      this.results = [];
      this.failedCount = 0;
      this.length = 0;
      this.timer = null;
      this.position = 0;
      this.positions = "|/-\\";
    }

    HeadlessConsoleReporter.prototype.reportRunnerResults = function(runner) {
      var output, result, resultLine, runtime, _i, _len, _ref;
      if (this.hasError()) return;
      runtime = (new Date() - this.startTime) / 1000.0;
      JHW.stdout.print("\n");
      resultLine = this._formatResultLine(runtime);
      if (this.failedCount === 0) {
        JHW.stdout.puts(("PASS: " + resultLine).foreground('green'));
      } else {
        JHW.stdout.puts(("FAIL: " + resultLine).foreground('red'));
        JHW.hasSpecFailure();
      }
      output = "TOTAL||" + this.length + "||" + this.failedCount + "||" + runtime + "||" + (JHW._hasErrors ? "T" : "F");
      JHW.report.puts(output);
      _ref = this.results;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        result = _ref[_i];
        JHW.stdout.puts(result.toString());
      }
      if (window.JHW) window.onbeforeunload = null;
      return JHW.finishSuite();
    };

    HeadlessConsoleReporter.prototype.reportRunnerStarting = function(runner) {
      this.startTime = new Date();
      if (!this.hasError()) {
        return JHW.stdout.puts("\nRunning Jasmine specs...".bright());
      }
    };

    HeadlessConsoleReporter.prototype.reportSpecResults = function(spec) {
      var failureResult, foundLine, result, results, testCount, _i, _len, _ref;
      if (this.hasError()) return;
      JHW.ping();
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

    HeadlessConsoleReporter.prototype.reportSpecStarting = function(spec) {
      if (this.hasError()) {
        spec.finish();
        return spec.suite.finish();
      }
    };

    HeadlessConsoleReporter.prototype.reportSpecWaiting = function() {
      var first, runner;
      var _this = this;
      runner = null;
      if (!this.timer) {
        this.timer = true;
        first = true;
        runner = function() {
          return _this.timer = setTimeout(function() {
            if (_this.timer) {
              if (!first) JHW.stdout.print(Intense.moveBack());
              JHW.stdout.print(_this.positions.substr(_this.position, 1).foreground('yellow'));
              _this.position += 1;
              _this.position %= _this.positions.length;
              first = false;
              return runner();
            }
          }, 750);
        };
        return runner();
      }
    };

    HeadlessConsoleReporter.prototype.reportSpecRunning = function() {
      if (this.timer) {
        clearTimeout(this.timer);
        this.timer = null;
        return JHW.stdout.print(Intense.moveBack());
      }
    };

    HeadlessConsoleReporter.prototype.reportSuiteResults = function(suite) {};

    HeadlessConsoleReporter.prototype.hasError = function() {
      return JHW._hasErrors;
    };

    HeadlessConsoleReporter.prototype._formatResultLine = function(runtime) {
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

    return HeadlessConsoleReporter;

  })();
