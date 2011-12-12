
  if (!(typeof jasmine !== "undefined" && jasmine !== null)) {
    throw new Error("jasmine not loaded!");
  }

  jasmine.HeadlessReporter = (function() {

    function HeadlessReporter(callback) {
      this.callback = callback != null ? callback : null;
      this.results = [];
      this.failedCount = 0;
      this.length = 0;
      this.timer = null;
    }

    HeadlessReporter.prototype.hasError = function() {
      return JHW._hasErrors;
    };

    HeadlessReporter.prototype.reportSpecStarting = function(spec) {
      if (this.hasError()) {
        spec.finish();
        return spec.suite.finish();
      }
    };

    HeadlessReporter.prototype.reportSuiteResults = function(suite) {};

    HeadlessReporter.prototype.reportRunnerStarting = function(runner) {
      return this.startTime = new Date();
    };

    HeadlessReporter.prototype.reportRunnerResults = function(runner) {
      if (this.hasError()) return;
      if (this.failedCount !== 0) JHW.hasSpecFailure();
      return JHW.finishSuite();
    };

    HeadlessReporter.prototype.reportSpecResults = function(spec) {
      if (this.hasError()) return;
      return JHW.ping();
    };

    HeadlessReporter.prototype._reportSpecResult = function(spec, options) {
      var results;
      results = spec.results();
      this.length++;
      if (results.passed()) {
        return options.success(results, spec);
      } else {
        this.failedCount++;
        return options.failure(results, spec);
      }
    };

    HeadlessReporter.prototype._runtime = function() {
      return (new Date() - this.startTime) / 1000.0;
    };

    return HeadlessReporter;

  })();
