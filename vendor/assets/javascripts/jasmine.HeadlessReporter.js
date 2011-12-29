(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  if (!(typeof jasmine !== "undefined" && jasmine !== null)) {
    throw new Error("jasmine not loaded!");
  }

  jasmine.HeadlessReporter = (function() {

    function HeadlessReporter(outputTarget) {
      this.outputTarget = outputTarget != null ? outputTarget : null;
      this.puts = __bind(this.puts, this);
      this.print = __bind(this.print, this);
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
      JHW.finishSuite();
      if (window.JHW) return window.onbeforeunload = null;
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

    HeadlessReporter.prototype.print = function(output) {
      return JHW.print(this.outputTarget, output);
    };

    HeadlessReporter.prototype.puts = function(output) {
      return JHW.print(this.outputTarget, output + "\n");
    };

    return HeadlessReporter;

  })();

}).call(this);
