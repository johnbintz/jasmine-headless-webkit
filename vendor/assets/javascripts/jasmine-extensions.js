(function() {
  var getSplitName, pauseAndRun;

  if (!(typeof jasmine !== "undefined" && jasmine !== null)) {
    throw new Error("jasmine not laoded!");
  }

  if (window.JHW) {
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
      if (specLineInfo.file) {
        parts.push("" + specLineInfo.file + ":" + specLineInfo.lineNumber);
      } else {
        parts.push('');
      }
      return parts.join("||");
    };
    jasmine.Spec.prototype.finishCallback = function() {
      JHW.ping();
      return this.env.reporter.reportSpecResults(this);
    };
    jasmine.Spec.prototype.fail = function(e) {
      var expectationResult, filename, realFilename;
      if (e && e.sourceURL && window.CoffeeScriptToFilename) {
        filename = e.sourceURL.split('/').pop();
        if (realFilename = window.CoffeeScriptToFilename[filename]) {
          e = {
            name: e.name,
            message: e.message,
            lineNumber: "~" + String(e.line),
            sourceURL: realFilename
          };
        }
      }
      expectationResult = new jasmine.ExpectationResult({
        passed: false,
        message: e ? jasmine.util.formatException(e) : 'Exception',
        trace: {
          stack: e.stack
        }
      });
      return this.results_.addResult(expectationResult);
    };
    jasmine.NestedResults.isValidSpecLine = function(line) {
      return line.match(/^\s*expect/) !== null || line.match(/^\s*return\s*expect/) !== null;
    };
    jasmine.NestedResults.parseFunction = function(func) {
      var line, lineCount, lines, _i, _len, _ref;
      lines = [];
      lineCount = 0;
      _ref = func.split("\n");
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        if (jasmine.NestedResults.isValidSpecLine(line)) {
          line = line.replace(/^\s*/, '').replace(/\s*$/, '').replace(/^return\s*/, '');
          lines.push([line, lineCount]);
        }
        lineCount += 1;
      }
      return lines;
    };
    jasmine.NestedResults.parseAndStore = function(func) {
      if (!jasmine.NestedResults.ParsedFunctions[func]) {
        jasmine.NestedResults.ParsedFunctions[func] = jasmine.NestedResults.parseFunction(func);
      }
      return jasmine.NestedResults.ParsedFunctions[func];
    };
    jasmine.NestedResults.ParsedFunctions = [];
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
      jasmine.NestedResults.prototype.addResult_ = jasmine.NestedResults.prototype.addResult;
      jasmine.NestedResults.prototype.addResult = function(result) {
        result.expectations = [];
        result.expectations = jasmine.NestedResults.parseAndStore(arguments.callee.caller.caller.caller.toString());
        return this.addResult_(result);
      };
    }
  }

}).call(this);
