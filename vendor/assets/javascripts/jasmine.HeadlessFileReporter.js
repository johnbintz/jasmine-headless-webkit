(function() {
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  jasmine.HeadlessFileReporter = (function() {

    __extends(HeadlessFileReporter, jasmine.HeadlessReporter);

    function HeadlessFileReporter() {
      HeadlessFileReporter.__super__.constructor.apply(this, arguments);
    }

    HeadlessFileReporter.prototype.reportRunnerResults = function(runner) {
      var output;
      HeadlessFileReporter.__super__.reportRunnerResults.call(this, runner);
      output = "TOTAL||" + this.length + "||" + this.failedCount + "||" + (this._runtime()) + "||" + (JHW._hasErrors ? "T" : "F");
      this.puts(output);
      return this.puts("SEED||" + (JHW.getSeed()));
    };

    HeadlessFileReporter.prototype.consoleLogUsed = function(msg) {
      return this.puts("CONSOLE||" + msg);
    };

    HeadlessFileReporter.prototype.reportSpecResults = function(spec) {
      var _this = this;
      HeadlessFileReporter.__super__.reportSpecResults.call(this, spec);
      return this._reportSpecResult(spec, {
        success: function(results) {
          return _this.puts("PASS||" + spec.getJHWSpecInformation());
        },
        failure: function(results) {
          return _this.puts("FAIL||" + spec.getJHWSpecInformation());
        }
      });
    };

    return HeadlessFileReporter;

  })();

}).call(this);
