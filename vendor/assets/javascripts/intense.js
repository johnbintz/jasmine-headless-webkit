(function() {
  var code, method, _ref;

  window.Intense = {
    colors: {
      black: 0,
      red: 1,
      green: 2,
      yellow: 3,
      blue: 4,
      magenta: 5,
      cyan: 6,
      white: 7
    },
    methods: {
      foreground: function(color) {
        if (Intense.useColors) {
          return "\033[3" + Intense.colors[color] + "m" + this + "\033[0m";
        } else {
          return this;
        }
      },
      bright: function() {
        if (Intense.useColors) {
          return "\033[1m" + this + "\033[0m";
        } else {
          return this;
        }
      }
    },
    useColors: true,
    moveBack: function(count) {
      if (count == null) count = 1;
      return "\033[" + count + "D";
    }
  };

  _ref = Intense.methods;
  for (method in _ref) {
    code = _ref[method];
    String.prototype[method] = code;
  }

}).call(this);
