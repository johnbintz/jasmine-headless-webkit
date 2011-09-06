(function() {
  var getSplitName, pauseAndRun;
  if (!(typeof jasmine !== "undefined" && jasmine !== null)) {
    throw new Error("jasmine not laoded!");
  }
  getSplitName = function(parts) {
    parts.push(String(this.description).replace(/[\n\r]/g, ' '));
    return parts;
  };
  jasmine.Suite.prototype.getSuiteSplitName = function() {
    return this.getSplitName(this.parentSuite ? this.parentSuite.getSuiteSplitName() : []);
  };
  jasmine.Spec.prototype.getSpecSplitName = function() {
    return this.getSplitName(this.suite.getSuiteSplitName());
  };
  jasmine.Suite.prototype.getSplitName = getSplitName;
  jasmine.Spec.prototype.getSplitName = getSplitName;
  jasmine.Spec.prototype.getJHWSpecInformation = function() {
    var parts, specLineInfo;
    parts = this.getSpecSplitName();
    specLineInfo = HeadlessReporterResult.findSpecLine(parts);
    parts.push("" + specLineInfo.file + ":" + specLineInfo.lineNumber);
    return parts.join("||");
  };
  if (!jasmine.WaitsBlock.prototype._execute) {
    jasmine.WaitsBlock.prototype._execute = jasmine.WaitsBlock.prototype.execute;
    jasmine.WaitsForBlock.prototype._execute = jasmine.WaitsForBlock.prototype.execute;
    pauseAndRun = function(onComplete) {
      JHW.timerPause();
      return this._execute(function() {
        JHW.timerDone();
        return onComplete();
      });
    };
    jasmine.WaitsBlock.prototype.execute = pauseAndRun;
    jasmine.WaitsForBlock.prototype.execute = pauseAndRun;
  }
  window.HeadlessReporterResult = (function() {
    function HeadlessReporterResult(name, splitName) {
      this.name = name;
      this.splitName = splitName;
      this.results = [];
    }
    HeadlessReporterResult.prototype.addResult = function(message) {
      return this.results.push(message);
    };
    HeadlessReporterResult.prototype.print = function() {
      var bestChoice, output, result, _i, _len, _ref, _results;
      output = this.name;
      bestChoice = HeadlessReporterResult.findSpecLine(this.splitName);
      if (bestChoice.file) {
        output += " (" + bestChoice.file + ":" + bestChoice.lineNumber + ")";
      }
      JHW.printName(output);
      _ref = this.results;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        result = _ref[_i];
        _results.push(JHW.printResult(result));
      }
      return _results;
    };
    HeadlessReporterResult.findSpecLine = function(splitName) {
      var bestChoice, file, index, lastLine, line, lineNumber, lines, newLineNumberInfo, _i, _len, _ref;
      bestChoice = {
        accuracy: 0,
        file: null,
        lineNumber: null
      };
      _ref = HeadlessReporterResult.specLineNumbers;
      for (file in _ref) {
        lines = _ref[file];
        index = 0;
        lineNumber = 0;
        while (newLineNumberInfo = lines[splitName[index]]) {
          if (newLineNumberInfo.length === 0) {
            lineNumber = newLineNumberInfo[0];
          } else {
            lastLine = null;
            for (_i = 0, _len = newLineNumberInfo.length; _i < _len; _i++) {
              line = newLineNumberInfo[_i];
              lastLine = line;
              if (line > lineNumber) {
                break;
              }
            }
            lineNumber = lastLine;
          }
          index++;
        }
        if (index > bestChoice.accuracy) {
          bestChoice = {
            accuracy: index,
            file: file,
            lineNumber: lineNumber
          };
        }
      }
      return bestChoice;
    };
    return HeadlessReporterResult;
  })();
  jasmine.HeadlessReporter = (function() {
    function HeadlessReporter(callback) {
      this.callback = callback != null ? callback : null;
      this.results = [];
      this.failedCount = 0;
      this.length = 0;
    }
    HeadlessReporter.prototype.reportRunnerResults = function(runner) {
      var result, _i, _len, _ref;
      if (this.hasError()) {
        return;
      }
      _ref = this.results;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        result = _ref[_i];
        result.print();
      }
      if (this.callback) {
        this.callback();
      }
      return JHW.finishSuite((new Date() - this.startTime) / 1000.0, this.length, this.failedCount);
    };
    HeadlessReporter.prototype.reportRunnerStarting = function(runner) {
      return this.startTime = new Date();
    };
    HeadlessReporter.prototype.reportSpecResults = function(spec) {
      var failureResult, result, results, _i, _len, _ref;
      if (this.hasError()) {
        return;
      }
      results = spec.results();
      this.length++;
      if (results.passed()) {
        return JHW.specPassed(spec.getJHWSpecInformation());
      } else {
        JHW.specFailed(spec.getJHWSpecInformation());
        this.failedCount++;
        failureResult = new HeadlessReporterResult(spec.getFullName(), spec.getSpecSplitName());
        _ref = results.getItems();
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          result = _ref[_i];
          if (result.type === 'expect' && !result.passed_) {
            failureResult.addResult(result.message);
          }
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
      return JHW.hasError();
    };
    return HeadlessReporter;
  })();
}).call(this);
