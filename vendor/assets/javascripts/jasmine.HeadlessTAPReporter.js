(function() {
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  jasmine.HeadlessTAPReporter = (function() {

    __extends(HeadlessTAPReporter, jasmine.HeadlessReporter);

    function HeadlessTAPReporter(outputTarget) {
      this.outputTarget = outputTarget != null ? outputTarget : null;
      HeadlessTAPReporter.__super__.constructor.call(this, this.outputTarget);
      this.output = [];
    }

    HeadlessTAPReporter.prototype.reportRunnerResults = function(runner) {
      HeadlessTAPReporter.__super__.reportRunnerResults.call(this, runner);
      if (this.output.length > 0) this.output.unshift("1.." + this.output.length);
      return this.puts(this.output.join("\n"));
    };

    HeadlessTAPReporter.prototype.reportSpecResults = function(spec) {
      var description, index;
      var _this = this;
      HeadlessTAPReporter.__super__.reportSpecResults.call(this, spec);
      index = this.output.length + 1;
      description = spec.getSpecSplitName().join(' ');
      return this._reportSpecResult(spec, {
        success: function(results) {
          return _this.output.push("ok " + index + " " + description);
        },
        failure: function(results) {
          return _this.output.push("not ok " + index + " " + description);
        }
      });
    };

    return HeadlessTAPReporter;

  })();

}).call(this);
