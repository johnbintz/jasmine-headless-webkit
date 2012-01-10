(function() {
  var __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  jasmine.HeadlessReporter.File = (function(_super) {

    __extends(File, _super);

    function File() {
      File.__super__.constructor.apply(this, arguments);
    }

    File.prototype.reportRunnerResults = function(runner) {
      var output;
      File.__super__.reportRunnerResults.call(this, runner);
      output = "TOTAL||" + this.length + "||" + this.failedCount + "||" + (this._runtime()) + "||" + (JHW._hasErrors ? "T" : "F");
      this.puts(output);
      return this.puts("SEED||" + (JHW.getSeed()));
    };

    File.prototype.consoleLogUsed = function(msg) {
      return this.puts("CONSOLE||" + msg);
    };

    File.prototype.reportSpecResults = function(spec) {
      var _this = this;
      File.__super__.reportSpecResults.call(this, spec);
      return this._reportSpecResult(spec, {
        success: function(results) {
          return _this.puts("PASS||" + spec.getJHWSpecInformation());
        },
        failure: function(results) {
          return _this.puts("FAIL||" + spec.getJHWSpecInformation());
        }
      });
    };

    return File;

  })(jasmine.HeadlessReporter);

}).call(this);
