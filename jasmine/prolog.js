(function() {
  var createHandle, handle, _i, _len, _ref;
  if (window.JHW) {
    window.console = {
      log: function(data) {
        var dump, useJsDump;
        if (typeof jQuery !== 'undefined' && data instanceof jQuery) {
          return JHW.log(style_html($("<div />").append(data).html(), {
            indent_size: 2
          }));
        } else {
          useJsDump = true;
          try {
            if (typeof data.toJSON === 'function') {
              JHW.log("JSON: " + (JSON.stringify(data, null, 2)));
              useJsDump = false;
            }
          } catch (e) {

          }
          if (useJsDump) {
            dump = jsDump.doParse(data);
            if (dump.indexOf("\n") === -1) {
              return JHW.log(dump);
            } else {
              return JHW.log("jsDump: " + dump);
            }
          }
        }
      },
      pp: function(data) {
        return JHW.log(jasmine ? jasmine.pp(data) : console.log(data));
      },
      peek: function(data) {
        console.log(data);
        return data;
      }
    };
    window.onbeforeunload = function(e) {
      JHW.leavePageAttempt();
      JHW.stderr.puts('The code tried to leave the test page. Check for unhandled form submits and link clicks.');
      if (e = e || window.event) {
        e.returnValue = "leaving";
      }
      return "leaving";
    };
    window.confirm = function(message) {
      JHW.stderr.puts("jasmine-headless-webkit can't handle confirm() yet! You should mock window.confirm. Returning true.");
      return true;
    };
    window.alert = function(message) {
      return JHW.stderr.puts(message);
    };
    JHW._hasErrors = false;
    JHW._handleError = function(message, lineNumber, sourceURL) {
      JHW.stderr.puts(message);
      JHW._hasErrors = true;
      return false;
    };
    JHW._setColors = function(what) {
      return Intense.useColors = what;
    };
    createHandle = function(handle) {
      return JHW[handle] = {
        print: function(content) {
          return JHW.print(handle, content);
        },
        puts: function(content) {
          return JHW.print(handle, content + "\n");
        }
      };
    };
    _ref = ['stdout', 'stderr', 'report'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      handle = _ref[_i];
      createHandle(handle);
    }
    JHW.log = function(msg) {
      JHW.usedConsole();
      return JHW.stdout.puts(msg);
    };
  }
}).call(this);
