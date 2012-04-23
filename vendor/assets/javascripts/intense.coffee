window.Intense = {
  colors:
    black: 0
    red: 1
    green: 2
    yellow: 3
    blue: 4
    magenta: 5
    cyan: 6
    white: 7
  methods:
    foreground: (color) ->
      if Intense.useColors
        '\x1b' + "[3#{Intense.colors[color]}m#{this}" + '\x1b' + "[0m"
      else
        this
    bright: ->
      if Intense.useColors
        '\x1b' + "[1m#{this}" + '\x1b' + "[0m"
      else
        this
  useColors: true
  moveBack: (count = 1) -> '\x1b' + "[#{count}D"
}

for method, code of Intense.methods
  String.prototype[method] = code

