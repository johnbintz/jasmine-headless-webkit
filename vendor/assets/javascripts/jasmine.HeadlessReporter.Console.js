(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  jasmine.HeadlessReporter.Console = (function(_super) {

    __extends(Console, _super);

    function Console() {
      this.displayFailure = __bind(this.displayFailure, this);
      this.displaySuccess = __bind(this.displaySuccess, this);
      Console.__super__.constructor.apply(this, arguments);
    }

    Console.prototype.displaySuccess = function(spec) {
      return this.print('.'.foreground('green'));
    };

    Console.prototype.displayFailure = function(spec) {
      return this.print('F'.foreground('red'));
    };

    return Console;

  })(jasmine.HeadlessReporter.ConsoleBase);

}).call(this);
