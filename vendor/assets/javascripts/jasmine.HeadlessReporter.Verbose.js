(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  jasmine.HeadlessReporter.Verbose = (function() {

    __extends(Verbose, jasmine.HeadlessReporter.ConsoleBase);

    function Verbose() {
      this.colorLine = __bind(this.colorLine, this);
      this.indentLines = __bind(this.indentLines, this);
      this.indentSpec = __bind(this.indentSpec, this);
      this.displaySpec = __bind(this.displaySpec, this);
      this.displayFailure = __bind(this.displayFailure, this);
      this.displaySuccess = __bind(this.displaySuccess, this);
      Verbose.__super__.constructor.apply(this, arguments);
    }

    Verbose.prototype.displaySuccess = function(spec) {
      return this.displaySpec(spec, 'green');
    };

    Verbose.prototype.displayFailure = function(spec) {
      return this.displaySpec(spec, 'red');
    };

    Verbose.prototype.displaySpec = function(spec, color) {
      var currentLastNames;
      currentLastNames = (this.lastNames || []).slice(0);
      this.lastNames = spec.getSpecSplitName();
      return this.puts(this.indentSpec(this.lastNames, currentLastNames, color).join("\n"));
    };

    Verbose.prototype.indentSpec = function(current, last, color) {
      var lines, name, _i, _len;
      last = last.slice(0);
      lines = [];
      for (_i = 0, _len = current.length; _i < _len; _i++) {
        name = current[_i];
        if (last.shift() !== name) {
          lines.push(name);
        } else {
          lines.push(null);
        }
      }
      return this.indentLines(lines, color);
    };

    Verbose.prototype.indentLines = function(lines, color) {
      var indent, line, output, outputLine, _i, _len;
      indent = '';
      output = [];
      for (_i = 0, _len = lines.length; _i < _len; _i++) {
        line = lines[_i];
        if (line != null) {
          outputLine = indent;
          outputLine += this.colorLine(line, color);
          output.push(outputLine);
        }
        indent += '  ';
      }
      return output;
    };

    Verbose.prototype.colorLine = function(line, color) {
      return line.foreground(color);
    };

    return Verbose;

  })();

}).call(this);
