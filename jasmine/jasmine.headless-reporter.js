(function() {
  var HeadlessReporterResult;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  if (!(typeof jasmine !== "undefined" && jasmine !== null)) {
    throw new Exception("jasmine not laoded!");
  }
  HeadlessReporterResult = (function() {
    function HeadlessReporterResult(name) {
      this.name = name;
      this.results = [];
    }
    HeadlessReporterResult.prototype.addResult = function(message) {
      return this.results.push(message);
    };
    HeadlessReporterResult.prototype.print = function() {
      var result, _i, _len, _ref, _results;
      JHW.printName(this.name);
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
    return HeadlessReporterResult;
  })();
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
      if (results.passed()) {
        return JHW.specPassed();
      } else {
        JHW.specFailed();
        failureResult = new HeadlessReporterResult(spec.getFullName());
        _ref = results.getItems();
        _fn = __bind(function(result) {
          if (result.type === 'expect' && !result.passed_) {
            this.failedCount += 1;
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
    HeadlessReporter.prototype.reportSuiteResults = function(suite) {
      return this.length += suite.specs().length;
    };
    return HeadlessReporter;
  })();
}).call(this);
