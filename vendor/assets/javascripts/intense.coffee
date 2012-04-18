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
        "\x33[3#{Intense.colors[color]}m#{this}\x33[0m"
      else
        this
    bright: ->
      if Intense.useColors
        "\x33[1m#{this}\x33[0m"
      else
        this
  useColors: true
  moveBack: (count = 1) -> "\033[#{count}D"
}

for method, code of Intense.methods
  String.prototype[method] = code

