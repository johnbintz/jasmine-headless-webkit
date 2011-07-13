(function() {
  var HeadlessReporterResult;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  if (!(typeof jasmine !== "undefined" && jasmine !== null)) {
    throw new Error("jasmine not laoded!");
  }
  HeadlessReporterResult = (function() {
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
      bestChoice = this._findSpecLine();
      if (bestChoice.file) {
        output += " (" + bestChoice.file + ":" + bestChoice.lineNumber + ")";
      }
      JHW.printName(output);
      _ref = this.results;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        result = _ref[_i];
        _results.push(__bind(function(result) {
          return JHW.printResult(result);
        }, this)(result));
      }
      return _results;
    };
    HeadlessReporterResult.prototype._findSpecLine = function() {
      var bestChoice, file, index, lineNumber, lines, newLineNumber;
      bestChoice = {
        accuracy: 0,
        file: null,
        lineNumber: null
      };
      for (file in SPEC_LINE_NUMBERS) {
        lines = SPEC_LINE_NUMBERS[file];
        index = 0;
        while (newLineNumber = lines[this.splitName[index]]) {
          index++;
          lineNumber = newLineNumber;
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
  jasmine.Suite.prototype.getSuiteSplitName = function() {
    var parts;
    parts = this.parentSuite ? this.parentSuite.getSuiteSplitName() : [];
    parts.push(this.description);
    return parts;
  };
  jasmine.Spec.prototype.getSpecSplitName = function() {
    var parts;
    parts = this.suite.getSuiteSplitName();
    parts.push(this.description);
    return parts;
  };
  jasmine.HeadlessReporter = (function() {
    function HeadlessReporter() {
      this.results = [];
      this.failedCount = 0;
      this.length = 0;
    }
    HeadlessReporter.prototype.reportRunnerResults = function(runner) {
      var result, _fn, _i, _len, _ref;
      _ref = this.results;
      _fn = __bind(function(result) {
        return result.print();
      }, this);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        result = _ref[_i];
        _fn(result);
      }
      return JHW.finishSuite((new Date() - this.startTime) / 1000.0, this.length, this.failedCount);
    };
    HeadlessReporter.prototype.reportRunnerStarting = function(runner) {
      return this.startTime = new Date();
    };
    HeadlessReporter.prototype.reportSpecResults = function(spec) {
      var failureResult, result, results, _fn, _i, _len, _ref;
      results = spec.results();
      this.length++;
      if (results.passed()) {
        return JHW.specPassed();
      } else {
        JHW.specFailed(spec.getSpecSplitName().join('||'));
        this.failedCount++;
        failureResult = new HeadlessReporterResult(spec.getFullName(), spec.getSpecSplitName());
        _ref = results.getItems();
        _fn = __bind(function(result) {
          if (result.type === 'expect' && !result.passed_) {
            return failureResult.addResult(result.message);
          }
        }, this);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          result = _ref[_i];
          _fn(result);
        }
        return this.results.push(failureResult);
      }
    };
    HeadlessReporter.prototype.reportSpecStarting = function(spec) {};
    HeadlessReporter.prototype.reportSuiteResults = function(suite) {};
    return HeadlessReporter;
  })();
}).call(this);
