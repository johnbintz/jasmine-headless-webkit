(function() {

  window.HeadlessReporterResult = (function() {

    function HeadlessReporterResult(name, splitName) {
      this.name = name;
      this.splitName = splitName;
      this.results = [];
    }

    HeadlessReporterResult.prototype.addResult = function(message) {
      return this.results.push(message);
    };

    HeadlessReporterResult.prototype.toString = function() {
      var bestChoice, line, output, result, _i, _len, _ref;
      output = "\n" + this.name.foreground('red');
      bestChoice = HeadlessReporterResult.findSpecLine(this.splitName);
      if (bestChoice.file) {
        output += (" (" + bestChoice.file + ":" + bestChoice.lineNumber + ")").foreground('blue');
      }
      _ref = this.results;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        result = _ref[_i];
        line = result.message.foreground('red');
        if (result.lineNumber) {
          line += (" (line ~" + (bestChoice.lineNumber + result.lineNumber) + ")").foreground('red').bright();
        }
        output += "\n  " + line;
        if (result.line != null) {
          output += ("\n    " + result.line).foreground('yellow');
        }
      }
      return output;
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
              if (line > lineNumber) break;
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
        if (index === splitName.length) break;
      }
      return bestChoice;
    };

    return HeadlessReporterResult;

  })();

}).call(this);
